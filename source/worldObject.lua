local pd <const> = playdate
local gfx <const> = pd.graphics

WorldObject = {}

class('WorldObject').extends(gfx.sprite)

function WorldObject:init(x, y, img, zIndex, hasCollision)
    self:moveTo(x, y)
    self:setZIndex(4)
    self.useDrawMode = hasCollision ~= nil and hasCollision

    if img ~= nil then
        local sprite = gfx.image.new(img)
        self:setImage(sprite)
        if hasCollision then
            self:setCollideRect(50, 24, 40, 48)
        end

        self:setZIndex(zIndex)
    end

    self:add()
end

function WorldObject:update()
    if self.useDrawMode then
        self:setImageDrawMode(gfx.kDrawModeNXOR)
    end
end

SparkleParticle = {}

class('SparkleParticle').extends(WorldObject)

local spriteTable = gfx.imagetable.new("images/sparkleAnim/sparkleAnim")
local anim = gfx.animation.loop.new(100, spriteTable, true)

function SparkleParticle:init(x, y)
    SparkleParticle.super.init(self, x, y)
    self.anim = anim
    self.onPlayerOne = true
    self:setVisible(false)
    self:setZIndex(12)
end

function SparkleParticle:update()
    -- Add particle system over currently seletcted player while in character switch UI
    if CharacterUIActive then
        if not self:isVisible() then
            self:setVisible(true)

            -- Update position when reentering menu
            if PlayerOneActive then
                self:moveTo(Manny.x, Manny.y)
            else
                self:moveTo(Tati.x, Tati.y)
            end
        end

        self:setImage(self.anim:image()) -- loop animation

        -- Change position based on player selected
        if PlayerOneActive and not self.onPlayerOne then
            self.onPlayerOne = true
            self:moveTo(Manny.x, Manny.y)
        elseif not PlayerOneActive and self.onPlayerOne then
            self.onPlayerOne = false
            self:moveTo(Tati.x, Tati.y)
        end
    elseif self:isVisible() then -- Make sparkles invisible and and looping animation when exiting UI
        self:setVisible(false)
    end
end
