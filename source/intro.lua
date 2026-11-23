local pd <const> = playdate
local gfx <const> = pd.graphics

local bgImg = gfx.image.new("images/intro/introBorder")
local trees1 = gfx.image.new("images/intro/introTrees")
local street1 = gfx.image.new("images/intro/introStreet")

local streetSpeed = 3

MovingBG = {}

class('MovingBG').extends(gfx.sprite)

function MovingBG:init(x, y, img, speed)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:setImage(img)
    self:setZIndex(-1)
    self.speed = speed
    self:add()
end

function MovingBG:update()
    -- Loop moving images
    if self.x > 300 then
        self:moveTo(-300, 76)
    else
        self:moveBy(self.speed, 0)
    end
end

Intro = {}

class('Intro').extends(gfx.sprite)

function Intro:init()
    self:setCenter(0, 0)
    self:setZIndex(1)
    self:moveTo(0, 0)
    self:setImage(bgImg)
    local streetBG1 = MovingBG(0, 76, street1, streetSpeed)
    local streetBG2 = MovingBG(-300, 76, street1, streetSpeed)
    self:add()
end
