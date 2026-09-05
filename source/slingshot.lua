local pd <const> = playdate
local gfx <const> = pd.graphics

Slingshot = {}

local spriteSheet =
{
    branch = gfx.imagetable.new("images/pullObjects/branch/branchAnim")
}

class('Slingshot').extends(gfx.sprite)

function Slingshot:init(x, y, objectIndex)
    self:moveTo(x, y)
    self.pullAnim = gfx.animation.loop.new(100, spriteSheet.branch, true)
    self.pullAnim.startFrame = 1
    self.pullAnim.endFrame = 3
    self.endAnim = gfx.animation.loop.new(150, spriteSheet.branch, true)
    self.endAnim.startFrame = 4
    self.endAnim.endFrame = 5
    self.boing = false
    self.animCooldown = Timer(.6)
    self:setImage(self.pullAnim:image())
    self.index = 0
    self.finished = false
    self.trigger = Trigger(32, 116, 35, 42, 140, false, true)
    self:setZIndex(20)
    self:add()
end

function Slingshot:update()
    if self.trigger.active and not self.boing then
        --print(Manny.swingTargetTracker)
        if Manny.swingTargetTracker < 3 then
            self:setImage(spriteSheet.branch[Manny.swingTargetTracker + 1])
        else
            self.endAnim.frame = 1
            self.animCooldown.startTimer = true
            self.animCooldown.targetTime = pd.getElapsedTime() + self.animCooldown.totalTime
            self.boing = true
        end
    elseif self.boing then
        if not self.animCooldown.timeout then
            self:setImage(self.endAnim:image())
        end
    end
end
