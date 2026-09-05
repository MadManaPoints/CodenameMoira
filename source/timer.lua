local pd <const> = playdate
local gfx <const> = pd.graphics

Timer = {}

class('Timer').extends(gfx.sprite)

function Timer:init(totalTime)
    self.targetTime = pd.getElapsedTime() + totalTime
    self.totalTime = totalTime
    self.startTimer = false
    self.timeout = false
    self:add()
end

function Timer:update()
    if not self.startTimer then
        return
    end

    if pd.getElapsedTime() > self.targetTime and not self.timeout then
        self.timeout = true
        --self.targetTime = pd.getElapsedTime() + self.totalTime
    end
end
