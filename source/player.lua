local pd <const> = playdate
local gfx <const> = pd.graphics

Player = {}


class('Player').extends(gfx.sprite)

function Player:init(x, y, alone, isPlayerOne)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self:setCollideRect(5, 3, 13, 18)

    self.playerControl = true

    -- Movement --
    self.currentDir = nil
    self.allDir = { "up", "down", "left", "right" }
    self.heldDir = {}

    self.isPlayerOne = isPlayerOne
    self.ability1, self.ability2 = false, false
    self.onTrigger = false
    self.triggerInfo = nil

    self.anim = nil

    -- Initialize follower variables if players are together in scene
    if not alone then
        if not isPlayerOne then
            self.following = false
            self:setCollidesWithGroups(1)
            self.prevX = x + 32
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

    local tag = isPlayerOne and 1 or 2
    self:setTag(tag)
    self:setGroups(2)
    self:setZIndex(5)
    self:add()
end

function Player:update()
    -- Checkpoint --
    if self.ded then
        --self:swordManager()
        self:moveTo(CurrentCheckpointX, CurrentCheckpointY)
        if self.x == CurrentCheckpointX and self.y == CurrentCheckpointY then self.ded = false end
        return
    end

    if not self.onLog then
        self:setImage(self.anim:image())
        self:animationManager()
        self:itemSelect()
    end

    if not self.following then
        if self.alone then
            self:abilityManager()
        end

        self:switchRooms(self.x, self.y)

        if not self.playerControl then
            return
        end

        local goalX, goalY = self.x, self.y

        self:directionalInputs()
        self:movement(goalX, goalY)
    else
        local goalX, goalY = self.x, self.y

        self:followPartner(goalX, goalY)
    end
end

function Player:directionalInputs()
    -- detect most recent button pressed
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

function Player:movement(_goalX, _goalY)

end

function Player:followPartner(_goalX, _goalY)

end

function Player:abilityManager()

end

function Player:animationManager()

end

function Player:itemSelect()
    if not self.ability2 and pd.buttonJustPressed("A") then
        self:abilityOne()
    end
    if not self.ability1 and pd.buttonJustPressed("B") then
        self:abilityTwo()
    end
end

function Player:abilityOne()

end

function Player:abilityTwo()

end

function Player:switchRooms(x, y)
    -- loop through all rooms and choose next room based on where player exits
    if x < 0 then
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                --if sword ~= nil then sword = nil end
                GAME_MANAGER:switchScene(Room(r.left, "images/rooms/night1/room" .. tostring(r.left)), 388, y,
                    self.isPlayerOne)
                break
            end
        end
    end
    if x > 400 then
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                GAME_MANAGER:switchScene(Room(r.right, "images/rooms/night1/room" .. tostring(r.right)), 12, y,
                    self.isPlayerOne)
                break
            end
        end
    end
    if y < 0 then
        local newX = x
        --print(newX)
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                GAME_MANAGER:switchScene(Room(r.up, "images/rooms/night1/room" .. tostring(r.up)), newX, 228,
                    self.isPlayerOne)
            end
        end
    end
    if y > 240 then
        --if state == states.climbing then
        --    self.playerControl = true
        --    state = states.idle
        --end
        local newX = x
        --print(newX)
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                if r.id == 4 then
                    self.isPlayerOne = true
                    GAME_MANAGER:switchScene(Room(1, "images/rooms/night1/room1"), 380, 100,
                        self.isPlayerOne)
                    break
                else
                    GAME_MANAGER:switchScene(Room(r.down, "images/rooms/night1/room" .. tostring(r.down)), newX, 12,
                        self.isPlayerOne)
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
