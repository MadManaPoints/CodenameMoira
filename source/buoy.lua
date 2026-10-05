local pd <const> = playdate
local gfx <const> = pd.graphics

Buoy = {}

class('Buoy').extends(gfx.sprite)

local buoySpritesheet = gfx.imagetable.new("images/worldObjects/buoy/buoys")

function Buoy:init(x, y)
    self:moveTo(x, y)
    self.anim = gfx.animation.loop.new(150, buoySpritesheet, true)
    self:setZIndex(4)
    self:add()
end

function Buoy:update()
    self:setImage(self.anim:image())
end
