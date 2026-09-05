local pd <const> = playdate
local gfx <const> = pd.graphics

Collider = {}

class('Collider').extends(gfx.sprite)

function Collider:init(x, y, w, h)
    self:moveTo(x, y)
    self:setCollideRect(0, 0, w, h)
    self:setGroups(1)
    self:setTag(3)
    self.isTrigger = false
    self:add()
end

Water = {}

class('Water').extends(Collider)

function Water:init(x, y, w, h)
    Water.super.init(self, x, y, w, h)
    self:setGroups(6)
    self:setTag(4)
end

LogPole = {}

class('LogPole').extends(Collider)

function LogPole:init(x, y, w, h, index)
    LogPole.super.init(self, x, y, w, h)
    self.used = false
    self.index = index
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
    self.kCollisionTypeOverlap = true
    self.playerIsInside = false
    self:setGroups(6)
    self:setCollidesWithGroups(2)
    self:setTag(8)
end

function Trigger:update()
    --print(self:detectPlayer())
    if self:detectPlayer() and not self.active then
        self.active = true
        local collisions = self:overlappingSprites()
        for i = 1, #collisions do
            if collisions[i].onTrigger ~= nil then
                collisions[i].onTrigger = true
                if collisions[i]:getTag() == 1 then self.playerOne = true end
                collisions[i].triggerInfo = { self.x, self.y, self.playerGoal, self.jumpPlatform, self.grapple }
            end
        end
    elseif self.active and not self:detectPlayer() then
        if self.playerOne then
            Manny.onTrigger = false
            Manny.triggerInfo = nil
        else
            Tati.onTrigger = false
            Tati.triggerInfo = nil
        end
        self.active = false
    end
end

function Trigger:detectPlayer()
    if #self:overlappingSprites() == 1 then return true else return false end
end

Spray = {}

class('Spray').extends(Collider)

function Spray:init(x, y, w, h)
    Spray.super.init(self, x, y, w, h)
    self.kCollisionTypeOverlap = true
    local sprayTable = gfx.imagetable.new("images/spray/spray")
    self.anim = gfx.animation.loop.new(100, sprayTable, true)
    self:setCollidesWithGroups(4)
    self:setVisible(false)
    self:setCollisionsEnabled(false)
    self:setUpdatesEnabled(false)
    self:setCenter(0.5, 0.5)
    self:setGroups(7)
end

function Spray:update()
    --Collider.update(self)
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
