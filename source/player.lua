local pd <const> = playdate
local gfx <const> = pd.graphics

Player = {}

-- position to move sprite when entering new scene from each direction
local enterLeft, enterRight = 6, 394
local enterTop, enterBottom = 6, 234

local canSwitch = false
local switchTimer = Timer(.25)

local newSwitchTimer = nil


class('Player').extends(gfx.sprite)

function Player:init(x, y, alone, isPlayerOne, currentDir, abilityOneEquipped)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    --self:setCollideRect(5, 3, 13, 18) 24x24

    self.playerControl = true

    -- Movement --
    self.currentDir = currentDir
    self.allDir = { "up", "down", "left", "right" }
    self.heldDir = {}
    -- Add current direction if switching screens
    if self.currentDir ~= nil then table.insert(self.heldDir, self.currentDir) end
    self.halt = false

    self.isPlayerOne = isPlayerOne

    -- Check for current ability to persist between scenes
    -- (starts at ability one if current ability is not available)
    if abilityOneEquipped ~= nil then
        self.ability1 = abilityOneEquipped and true or false
        self.ability2 = abilityOneEquipped and true or false
    else
        self.ability1 = true
        self.ability2 = false
    end

    -- Info stored when stepping on trigger colliders (more in Collider.lua)
    self.onTrigger = false
    self.triggerInfo = nil

    self.anim = nil -- Animator (set in child scripts)

    -- Initialize follower variables if players are together in scene
    if not alone then
        if not isPlayerOne then
            self.following = false
            self:setCollidesWithGroups(1)
            self.prevX = x + 24
            self.prevY = y
        else
            self.following = true
            self.prevX = x
            self.prevY = y
        end
    else
        self:setCollidesWithGroups({ 1, 2, 3, 6 })
        self.ded = false
        self.following = false
        self.onLog = false
        self.alone = true
    end

    local tag = isPlayerOne and 1 or 2 -- Set tags used for collision responses
    self:setTag(tag)
    self:setGroups(2)                  -- Groups are used during collision responses
    self:setZIndex(5)

    -- One-time booleans used on first update frame
    self.abilityAdded = false
    self.roomEntered = false
end

function Player:update()
    -- Check for button presses when entering room
    if not self.roomEntered then
        self.roomEntered = true
        local directionCheck = false
        for i = 1, 4 do
            if pd.buttonIsPressed(self.allDir[i]) then directionCheck = true end
        end

        if not directionCheck then
            for i = 1, #self.heldDir do
                table.remove(self.heldDir, i)
            end
        end
    end

    -- Check and set current ability when entering room
    if not self.abilityAdded and not TwoPlayers then
        self.abilityAdded = true
        if self.ability1 then
            self:abilityOne()
        else
            self:abilityTwo()
        end
    end

    -- Ability switch UI in upper right-hand corner
    if not TwoPlayers then
        self:updateUI()
    end

    -- Checkpoint --
    if self.ded then
        -- Move player to checkpoint position on death, then reset ded variable
        --self:swordManager()
        self:moveTo(CurrentCheckpointX, CurrentCheckpointY)
        if self.x == CurrentCheckpointX and self.y == CurrentCheckpointY then self.ded = false end
        return
    end

    if not self.onLog then      -- Animation is handled differently when p1 is on log
        self:setImage(self.anim:image())
        self:animationManager() -- Updates animations based on player states

        -- Item select for respective player (only during night time)
        if not TwoPlayers and ((PlayerOneActive and self.isPlayerOne) or (not PlayerOneActive and not self.isPlayerOne)) then
            self:itemSelect()
        end
    end

    if not self.following then
        if self.alone then
            -- Room 6 is minigame one. SwitchManager is added only during minigames
            if RoomID == 6 and (PlayerOneActive and self.isPlayerOne) or (not PlayerOneActive and not self.isPlayerOne) then
                self:switchManager()
            end

            -- Update abilities for respective players
            if (PlayerOneActive and self.isPlayerOne) or (not PlayerOneActive and not self.isPlayerOne) then
                self:abilityManager()
            end
        end

        -- Update rooms when player moves on screen
        self:switchRooms(self.x, self.y)

        -- Prevent movement from updating when player control is false
        if not self.playerControl or Dialogue ~= nil then
            return
        end

        local goalX, goalY = self.x, self.y

        if (PlayerOneActive and self.isPlayerOne) or (not PlayerOneActive and not self.isPlayerOne) then
            self:directionalInputs()    -- Update direction based on d-pad input
            self:movement(goalX, goalY) -- Move player to new position (with collision)
        end
    else
        if (not PlayerOneActive and self.isPlayerOne) or (PlayerOneActive and not self.isPlayerOne) then
            self:switchManager()
        end


        local goalX, goalY = self.x, self.y
        self:followPartner(goalX, goalY) -- Follow currently selected player (without collision)
    end
end

function Player:directionalInputs()
    -- Detect most recent button pressed
    for i, dir in ipairs(self.allDir) do
        if pd.buttonJustPressed(dir) then
            if not table.indexOfElement(self.heldDir, dir) then
                table.insert(self.heldDir, dir)
            end
        end

        if pd.buttonJustReleased(dir) then
            if table.indexOfElement(self.heldDir, dir) then
                table.remove(self.heldDir, table.indexOfElement(self.heldDir, dir))
            end
        end
    end
end

function Player:switchManager()
    if not MinigameTrigger and not TwoPlayers then return end -- Only run this code block if in minigame

    if pd.buttonJustPressed("B") and not canSwitch then
        local function switchTimerUp()
            canSwitch = true -- callback for when timer ends
        end

        newSwitchTimer = pd.timer.new(500, switchTimerUp) -- create timer with .5 second duration
    end

    if canSwitch and not Switching then
        -- Make character switch UI visible after B has been held for a short period of time
        if MinigameTrigger or TwoPlayers then
            if not CharacterUIActive then CharacterUIActive = true end
        end
    end

    if canSwitch then
        if MinigameTrigger then
            -- Prevent players from moving when switching characters
            self.playerControl = false
            Manny.halt = true -- Needed to prevent movement on log during switch because movement is handled separately
        end
    end

    -- While character icons are active, allow player to press any d-pad button to switch between them
    if canSwitch and (pd.buttonJustPressed("Left") or pd.buttonJustPressed("Right")
            or pd.buttonJustPressed("Up") or pd.buttonJustPressed("Down")) and not Switching then
        Switching = true

        if not TwoPlayers then
            ChangeActivePlayer() -- Switch abilities and UI (night time)
        else
            ChangePlaces()       -- Switch places (day time)
        end
    end

    -- Prevent movement when exiting menu
    if pd.buttonJustReleased("B") then
        for i = 1, #self.heldDir do
            table.remove(self.heldDir, i)
        end

        if not canSwitch then
            newSwitchTimer:remove() -- remove timer if player released B button before callback
        end

        if canSwitch then
            canSwitch = false -- prevent switching upon release
        end

        if CharacterUIActive then CharacterUIActive = false end

        -- Return control to players unless player is on log (minigame 1)
        if not self.onLog and not self.playerControl then self.playerControl = true end
        if MinigameTrigger and Manny.halt then Manny.halt = false end -- Resume log movement
    end
end

function Player:itemSelect()
    if self.ability2 and pd.buttonJustPressed("A") then
        self:abilityOne()
    end
    if self.ability1 and pd.buttonJustReleased("B") and not canSwitch then
        self:abilityTwo()
    end
end

function Player:currentItemCheck()
    if self.ability1 then return true else return false end
end

function Player:switchRooms(x, y)
    -- loop through all rooms and choose next room based on where player exits
    if x < 0 then
        for k, r in pairs(Trackers.day.day1.rooms) do
            if r.id == RoomID then
                local _y
                if TwoPlayers then _y = PlayerOneActive and Manny.y or Tati.y end
                self:roomCheck()
                GAME_MANAGER:switchScene
                (
                    Room(r.left, "images/rooms/" .. CurrentTime .. tostring(CurrentDay) .. "/room" .. tostring(r.left)),
                    enterRight, y, true, self.isPlayerOne, self.currentDir, self:currentItemCheck()
                )
                break
            end
        end
    end

    if x > 400 then
        for k, r in pairs(Trackers.day.day1.rooms) do
            if r.id == RoomID then
                self:roomCheck()
                GAME_MANAGER:switchScene
                (
                    Room(r.right, "images/rooms/" .. CurrentTime .. tostring(CurrentDay) .. "/room" .. tostring(r.right)),
                    enterLeft, y,
                    true, self.isPlayerOne, self.currentDir, self:currentItemCheck()
                )
                break
            end
        end
    end
    if y < 0 then
        local newX = x
        for k, r in pairs(Trackers.night.night1.rooms) do
            if r.id == RoomID then
                self:roomCheck()
                GAME_MANAGER:switchScene
                (
                    Room(r.up, "images/rooms/night1/room" .. tostring(r.up)), newX, enterBottom,
                    nil, self.isPlayerOne, self.currentDir, self:currentItemCheck()
                )
                break
            end
        end
    end
    if y > 240 then
        local newX = x
        for k, r in pairs(Trackers.night.night1.rooms) do
            if r.id == RoomID then
                self:roomCheck()
                if r.id == 4 then
                    Meanwhile = true
                    self.playerControl = false
                    self.isPlayerOne = true
                    PlayerOneActive = true
                    GAME_MANAGER:switchScene
                    (
                        Room(1, "images/rooms/night1/room1"), 368, 100, nil, self.isPlayerOne
                    )
                    break
                elseif r.id == 3 then
                    GAME_MANAGER:switchScene
                    (
                        Room(r.down, "images/rooms/night1/room" .. tostring(r.down), true), newX, enterTop,
                        nil, self.isPlayerOne
                    )
                    break
                else
                    GAME_MANAGER:switchScene
                    (
                        Room(r.down, "images/rooms/night1/room" .. tostring(r.down)), newX, enterTop,
                        nil, self.isPlayerOne, self.currentDir, self:currentItemCheck()
                    )
                    break
                end
            end
        end
    end
end

function Player:collisionResponse(other)
    if other:isa(Breakable) then
        if other.broken then
            return 'overlap'
        else
            return 'freeze'
        end
    end

    if other:isa(Enemy) then
        if other.swarm then
            self.ded = true
            return 'overlap'
        end
    end
end

-- ***The follow functions are updated in child scripts***--
function Player:movement(_goalX, _goalY)

end

function Player:followPartner(_goalX, _goalY)

end

function Player:abilityManager()

end

function Player:animationManager()

end

function Player:updateUI()

end

function Player:abilityOne()

end

function Player:abilityTwo()

end

function Player:leftRoomCheck()

end

function Player:rightRoomCheck()

end

function Player:upRoomCheck()

end

function Player:rightRoomCheck()

end

function Player:roomCheck()

end
