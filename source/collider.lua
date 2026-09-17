local pd <const> = playdate
local gfx <const> = pd.graphics

Collider = {}

class('Collider').extends(gfx.sprite)

function Collider:init(x, y, w, h)
    self:moveTo(x, y)
    self:setGroups(1)
    self:setTag(3)
    self.isTrigger = false
    self:setCollideRect(0, 0, w, h)
    self:add()
end

Water = {}

class('Water').extends(Collider)

function Water:init(x, y, w, h)
    Water.super.init(self, x, y, w, h)
    self:setGroups(6)
    self:setTag(4)
end

Trigger = {}

class('Trigger').extends(Collider)

function Trigger:init(x, y, w, h, goal, isExit, isJumpPlatform, isGrapple)
    Trigger.super.init(self, x, y, w, h)
    self.isTrigger = true
    self.playerGoal = goal
    self.jumpPlatform = isJumpPlatform
    self.exit = isExit
    self.grapple = isGrapple
    self.active = false
    self.playerOne = false
    self.ignorePlayerOne = false
    self.kCollisionTypeOverlap = true
    self.playerIsInside = false
    self:setGroups(6)
    self:setCollidesWithGroups(2)
    self:setTag(8)
end

function Trigger:update()
    -- ***WARNING: STOP FORGETTING TO TURN THIS OFF OR YOU'LL COMPLETE THE MINIGAME RIGHT AWAY, DUMMY*** --
    --[[if pd.buttonJustReleased("Left") then
        self:exitResponse()
    end--]]

    --print(self:detectPlayer())
    if self:detectPlayer() then
        --print("PLAYER DETECTED")

        -- Active when a player in inside trigger
        if not self.active then self.active = true end

        -- Get overlapping players
        local collisions = self:overlappingSprites()

        for i = 1, #collisions do
            -- Detect which player in inside
            if collisions[i]:getTag() == 1 then self.playerOne = true end
            if collisions[i]:getTag() == 2 then self.playerOne = false end

            if self.ignorePlayerOne and self.playerOne then return end

            -- Let player know they're inside a trigger
            if collisions[i].onTrigger ~= nil and not collisions[i].onTrigger then
                collisions[i].onTrigger = true

                -- Switch scene if trigger is an exit
                if self.exit then
                    -- Ignore player 1 collider in first minigame
                    if self.minigameNum ~= nil and self.minigameNum == 0 and self.lose == false and self.playerOne then return end
                    self:resetPlayers()
                    self:exitResponse(self.playerOne)
                    return
                else
                    -- Fill triggerInfo array on player with info about this trigger
                    collisions[i].triggerInfo = { self.x, self.y, self.playerGoal, self.jumpPlatform, self.grapple }
                end
            end
        end
    elseif self.active and not self:detectPlayer() then
        -- Reset when player exits
        self:resetPlayers()
        self.active = false
    end
end

function Trigger:detectPlayer()
    -- True if any number of players overlap with trigger
    if #self:overlappingSprites() > 0 then return true else return false end
end

function Trigger:resetPlayers()
    if self.playerOne then
        Manny.onTrigger = false
        Manny.triggerInfo = nil
    else
        Tati.onTrigger = false
        Tati.triggerInfo = nil
    end
end

function Trigger:exitResponse(player)

end

LogPole = {}

class('LogPole').extends(Trigger)

function LogPole:init(x, y, w, h, goal, isExit, isJumpPlatform, isGrapple)
    LogPole.super.init(self, x, y, w, h, goal, isExit, isJumpPlatform, isGrapple)
    local sprite = gfx.image.new("images/worldObjects/log")
    self:setImage(sprite)
    self:setZIndex(4)
    self.used = false
    self.index = 1
    self:setCollideRect(5, 10, w, h)
end

function LogPole:update()
    LogPole.super.update(self)
    if self:isVisible() and Manny.onLog then -- remove log trigger sprite when player steps on log
        self:setVisible(false)
    end
end

Exit = {}

class('Exit').extends(Trigger)

function Exit:init(x, y, w, h, minigame, demoEnd, lose, ignorePlayerOne)
    Exit.super.init(self, x, y, w, h)
    self.exit = true
    self.demoEnd = demoEnd
    self.lose = lose
    self.minigameNum = minigame
    self.ignorePlayerOne = ignorePlayerOne
end

function Exit:update()
    Exit.super.update(self)
    if self.minigameNum == 0 and self.lose == false then
        local goalX, goalY = Manny.x - 24, Manny.y - 24

        local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
    end
end

function Exit:collisionResponse(other)
    if other:isa(Player) then
        return 'overlap'
    end
end

function Exit:exitResponse(playerOne)
    if self.demoEnd == nil then
        MinigameTrigger = true
    else
        if not playerOne then
            VictoryDictory = true
        end

        DemoEnd = true
    end
end

Spray = {}

class('Spray').extends(Collider)

function Spray:init(x, y, w, h)
    Spray.super.init(self, x, y, w, h)
    self.kCollisionTypeOverlap = true
    local sprayTable = gfx.imagetable.new("images/spray/spray")
    self.anim = gfx.animation.loop.new(100, sprayTable, true)
    self:setCollidesWithGroups(6)
    self:setVisible(false)
    self:setCollisionsEnabled(false)
    self:setUpdatesEnabled(false)
    self:setCenter(0.5, 0.5)
    self:setGroups(7)
end

function Spray:update()
    self:setImage(self.anim:image())
end

function Spray:changeDirection(x, y)
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(x, y)
end

function Spray:collisionResponse(other)
    if other:isa(Enemy) then
        other.ded = true
        return 'overlap'
    end
end
