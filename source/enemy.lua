local pd <const> = playdate
local gfx <const> = pd.graphics

Enemy = {}

class('Enemy').extends(gfx.sprite)

local spriteSheet =
{
    swarm = gfx.imagetable.new("images/swarmAnim/swarmAnim")
}

local swarmStart = gfx.animation.loop.new(200, spriteSheet.swarm, false)
local swarmIdle = gfx.animation.loop.new(200, spriteSheet.swarm, true)

swarmStart.startFrame = 1
swarmStart.endFrame = 6

swarmIdle.startFrame = 7
swarmIdle.endFrame = 9

function Enemy:init(x, y, isSwarm, isMoving)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self:setCollideRect(5, 3, 13, 18)
    self.swarm = isSwarm
    self.moving = isMoving
    self.anim = swarmStart
    self.ded = false
    self.updateTime = 0
    self.moveSpeed = 0.08
    self.startX = self.x
    self.startY = self.y
    self:setGroups(6)
    self:setCollidesWithGroups({ 1, 2, 7 })
    self:setTag(5)
    self:setZIndex(20)
    self:add()
end

function Enemy:update()
    if self.anim == swarmStart and self.anim.frame == swarmStart.endFrame then self.anim = swarmIdle end
    self:setImage(self.anim:image())

    if self.swarm and self.moving then
        self:move()
    end

    if self.ded then self:remove() end
end

function Enemy:move()
    local goalX, goalY = self.x, self.y

    if self.swarm then
        goalY = self.startY + math.sin(self.updateTime) * 26
        self.updateTime += self.moveSpeed
        local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
    end
end

function Enemy:collisionResponse(other)
    return 'overlap'
end
