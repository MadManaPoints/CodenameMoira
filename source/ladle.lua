local pd <const> = playdate
local gfx <const> = pd.graphics

Ladle = {}

local ladleSprite = gfx.image.new("images/ladle")
local dx = 0
local speed = 0.0027

local function map(value, minA, maxA, minB, maxB)
    local range = maxA - minA
    local valuePercent = (value - minA) / range

    local newRange = maxB - minB

    return valuePercent * newRange + minB
end

class('Ladle').extends(gfx.sprite)

function Ladle:init()
    self:setCenter(0.5, 0.5)
    self:moveTo(130, 70)
    self:setRotation(-30)
    self:setImage(ladleSprite)
    self:add()
end

function Ladle:update()
    -- Temp room switch --
    if pd.buttonJustPressed(pd.kButtonB) then
        GAME_MANAGER:enterTent(1)
    end

    local change, acceleratedChange = pd.getCrankChange()

    if change ~= 0 then dx += change * speed end

    local x = 200 + math.sin(dx) * 80
    local rot = map(x, 120, 280, -30, 30)
    self:moveTo(x, 70)
    self:setRotation(rot)

    fluid:touch(self.x, change * 0.02)
end
