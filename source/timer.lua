local pd <const> = playdate
local gfx <const> = pd.graphics

Timer = {}

class('Timer').extends(gfx.sprite)

function Timer:init(targetTime)
    self.targetTime = targetTime
    self.totalTime = targetTime
    self.startTimer = false
    self.timeout = false
    self:add()
end

function Timer:update()
    if not self.startTimer then return end

    if self.targetTime > 0 then
        self.targetTime -= Delta
    elseif not self.timeout then
        self.timeout = true
    end
end
