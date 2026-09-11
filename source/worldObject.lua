local pd <const> = playdate
local gfx <const> = pd.graphics

WorldObject = {}

class('WorldObject').extends(gfx.sprite)

function WorldObject:init(x, y, img)
    self:moveTo(x, y)
    self:setZIndex(4)
    local sprite = gfx.image.new(img)
    self:setImage(sprite)
    self:add()
end
