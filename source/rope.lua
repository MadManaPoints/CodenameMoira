local pd <const> = playdate
local gfx <const> = pd.graphics

Rope = {}

class('Rope').extends(gfx.sprite)

function Rope:init()
    self:moveTo(200, 120)
    self:setCenter(0.5, 0.5)
    self:setZIndex(3)
    self:add()
end

function Rope:update()
    if Manny.isClimbing then
        local lineImg = gfx.image.new(400, 240)
        local offsetX, offsetY = 200, 140
        gfx.lockFocus(lineImg)
        gfx.setColor(gfx.kColorWhite)
        gfx.setLineWidth(2.6)
        local backgroundLine = gfx.drawLine(Manny.x, Manny.y, RopeHookX, RopeHookY)
        gfx.setColor(gfx.kColorBlack)
        gfx.setLineWidth(1.4)
        local foregroundLine = gfx.drawLine(Manny.x, Manny.y, RopeHookX, RopeHookY)
        gfx.unlockFocus()
        self:setImage(lineImg)
    else
        self:remove()
    end
end
