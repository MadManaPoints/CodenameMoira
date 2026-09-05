local pd <const> = playdate
local gfx <const> = pd.graphics

Chopping = {}

local carrotSprite = gfx.imagetable.new("images/carrotTable/carrot")
--local anim = gfx.animation.loop.new(200, carrotSprite, true)

local canChop = false
local failedChop = false
local chopIndex = 1


class('Chopping').extends(gfx.sprite)

function Chopping:init()
    self:moveTo(200, 140)

    self:add()
end

function Chopping:update()
    local crank = pd.getCrankPosition()
    local change, acceleratedChange = pd.getCrankChange()
    local gravityX, gravityY, gravityZ = pd.readAccelerometer()

    self:setImage(carrotSprite:getImage(chopIndex))

    if gravityZ >= 0.6 then
        -- allow chop when crank is slightly raised while flat
        if not canChop and crank >= 200 and crank <= 250 then
            canChop = true
            if not failedChop and chopIndex < 16 then
                -- only add if player didn't rotate crank in the wrong direction
                chopIndex += 1
            end
        end

        -- prevent player from still chopping if they keep rotating crank
        if canChop and crank > 300 then
            failedChop = true
            canChop = false
        end

        if canChop and crank <= 180 and change < -10 then
            if chopIndex < 16 then
                chopIndex += 1
            end

            if failedChop then
                failedChop = false
            end

            canChop = false
        end
    else
        if canChop then
            canChop = false
            failedChop = true
        end
    end
end
