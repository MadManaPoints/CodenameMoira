local pd <const> = playdate
local gfx <const> = pd.graphics

Waterfall = {}

local img = gfx.imagetable.new("images/worldObjects/waterfall/waterfall")
local miniWaterfallImg = gfx.imagetable.new("images/worldObjects/miniFall/waterfall")

local rightSide = gfx.animation.loop.new(150, img, true)
rightSide.startFrame = 1
rightSide.endFrame = 2

local leftSide = gfx.animation.loop.new(150, img, true)
leftSide.startFrame = 3
leftSide.startFrame = 4

local miniWaterfall = gfx.animation.loop.new(200, miniWaterfallImg, true)

class('Waterfall').extends(gfx.sprite)

function Waterfall:init(x, y, miniFall, isLeftSide)
    self:moveTo(x, y)
    self:setCenter(0.5, 0.5)
    if miniFall then
        self.anim = miniWaterfall
    else
        self.anim = isLeftSide and leftSide or rightSide
    end
    self:setImage(self.anim:image())
    self:setZIndex(4)
    self:add()
end

function Waterfall:update()
    self:setImage(self.anim:image())
end
