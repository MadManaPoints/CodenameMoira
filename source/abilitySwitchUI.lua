local pd <const> = playdate
local gfx <const> = pd.graphics

AbilitySwitchUI = {}

class('AbilitySwitchUI').extends(gfx.sprite)

local sprites =
{
    sword = gfx.image.new("images/UI/swordPress"),
    broom = gfx.image.new("images/UI/broomPress"),
    rod = gfx.image.new("images/UI/rodPress"),
    spray = gfx.image.new("images/UI/sprayPress"),
    holdA = gfx.image.new("images/UI/holdA"),
    cast = gfx.image.new("images/UI/cast"),
    castAnim = gfx.imagetable.new("images/UI/castAnim/cast")
}

function AbilitySwitchUI:init()
    self:moveTo(358, 24)
    self:setGroups(10)
    self:setZIndex(10)
    self.anim = gfx.animation.loop.new(150, sprites.castAnim, true)
    self:add()
end

function AbilitySwitchUI:update()
    if PlayerOneActive then
        if Manny.triggerInfo ~= nil and not Manny.triggerInfo[4] and not Manny.triggerInfo[5] or Manny.isClimbing then
            if self:getImage() ~= sprites.holdA then
                self:resetAnimator()
                self:setImage(sprites.holdA)
            end
        elseif (Manny.triggerInfo ~= nil and Manny.triggerInfo[4]) or (Manny.onLog and not MinigameTrigger) then
            if self:getImage() ~= sprites.cast then
                if self.anim.paused then self.anim.paused = false end
                self:setImage(self.anim:image())
            end
        elseif Manny.ability1 and self:getImage() ~= sprites.rod then
            self:resetAnimator()
            self:setImage(sprites.rod)
        elseif Manny.ability2 and self:getImage() ~= sprites.spray then
            self:resetAnimator()
            self:setImage(sprites.spray)
        end
    else
        if Tati.ability1 and self:getImage() ~= sprites.sword then
            self:resetAnimator()
            self:setImage(sprites.sword)
        elseif Tati.ability2 and self:getImage() ~= sprites.broom then
            self:resetAnimator()
            self:setImage(sprites.broom)
        end
    end
end

function AbilitySwitchUI:resetAnimator()
    if self.anim.frame ~= 1 then
        self.anim.frame = 1
        self.anim.paused = true
    end
end
