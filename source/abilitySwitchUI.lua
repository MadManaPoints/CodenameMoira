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
    cast = gfx.image.new("images/UI/cast")
}

function AbilitySwitchUI:init()
    self:moveTo(358, 24)
    self:setGroups(10)
    self:setZIndex(10)
    self:add()
end

function AbilitySwitchUI:update()
    if PlayerOneActive then
        if Manny.triggerInfo ~= nil and not Manny.triggerInfo[4] and not Manny.triggerInfo[5] or Manny.isClimbing then
            if self:getImage() ~= sprites.holdA then
                self:setImage(sprites.holdA)
            end
        elseif (Manny.triggerInfo ~= nil and Manny.triggerInfo[4]) or (Manny.onLog and not MinigameTrigger) then
            if self:getImage() ~= sprites.cast then
                self:setImage(sprites.cast)
            end
        elseif Manny.ability1 and self:getImage() ~= sprites.rod then
            self:setImage(sprites.rod)
        elseif Manny.ability2 and self:getImage() ~= sprites.spray then
            self:setImage(sprites.spray)
        end
    else
        if Tati.ability1 and self:getImage() ~= sprites.sword then
            self:setImage(sprites.sword)
        elseif Tati.ability2 and self:getImage() ~= sprites.broom then
            self:setImage(sprites.broom)
        end
    end
end
