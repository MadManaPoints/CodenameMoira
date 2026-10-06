local pd <const> = playdate
local gfx <const> = pd.graphics

Cooldown = {}

local prevZ = 0

class('Cooldown').extends(gfx.sprite)

function Cooldown:init(x, y, max)
    self:moveTo(5, 210)
    self.max = -max
    self.current = self.max
    self:setZIndex(20)
    self:Bar(max)
    self:add()
end

function Cooldown:update()
    self:Bar(self.current)

    if pd.isCrankDocked() then
        local gravityX, gravityY, gravityZ = pd.readAccelerometer()
        local castStrength = math.abs(gravityZ - prevZ)

        if castStrength > 0.6 then
            if self.current < 0 then
                self.current += 3
            else
                self.current = 0
            end
        end

        prevZ = gravityZ
    end
end

function Cooldown:Bar(updateBar)
    local width = 11
    local maxHeight = 50
    local barHeight = (updateBar / self.max) * maxHeight
    local barImage = gfx.image.new(width, maxHeight)
    gfx.pushContext(barImage)
    gfx.setColor(gfx.kColorBlack)
    gfx.fillRect(0, barHeight, width, maxHeight + 10)
    gfx.popContext()
    self:setImage(barImage)
end
