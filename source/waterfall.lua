local pd <const> = playdate
local gfx <const> = pd.graphics

Waterfall = {}

local img = gfx.imagetable.new("images/worldObjects/waterfall/waterfall")

local rightSide = gfx.animation.loop.new(150, img, true)
rightSide.startFrame = 1
rightSide.endFrame = 2

local leftSide = gfx.animation.loop.new(150, img, true)
leftSide.startFrame = 3
leftSide.startFrame = 4

class('Waterfall').extends(gfx.sprite)

function Waterfall:init(x, y, isLeftSide)
    self:moveTo(x, y)
    self:setCenter(0.5, 0.5)
    self.anim = isLeftSide and leftSide or rightSide
    self:setImage(self.anim:image())
    self:setZIndex(50)
    self:add()
end

function Waterfall:update()
    self:setImage(self.anim:image())
end
