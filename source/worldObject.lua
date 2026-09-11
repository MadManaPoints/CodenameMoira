local pd <const> = playdate
local gfx <const> = pd.graphics

WorldObject = {}

class('WorldObject').extends(gfx.sprite)

function WorldObject:init(x, y, img, hasCollision)
    self:moveTo(x, y)
    self:setZIndex(4)
    self.useDrawMode = hasCollision ~= nil and hasCollision
    local sprite = gfx.image.new(img)
    self:setImage(sprite)
    if hasCollision then
        self:setCollideRect(50, 24, 40, 48)
        self:setZIndex(10)
    end
    self:add()
end

function WorldObject:update()
    if self.useDrawMode then
        self:setImageDrawMode(gfx.kDrawModeNXOR)
    end
end
