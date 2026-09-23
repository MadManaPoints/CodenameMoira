local pd <const> = playdate
local gfx <const> = pd.graphics

CharacterSwitchUI = {}

local activeX, activeY = 12, 228
local inactiveX, inactiveY = 20, 220
local moveSpeed = 5;
local co = nil
local updateScale = 0

class('CharacterSwitchUI').extends(gfx.sprite)

local p1, p2
local p1Anim, p2Anim

function CharacterSwitchUI:init()
    p1 = WorldObject(inactiveX, inactiveY, "images/characterCards/characterCard1", 10)
    p2 = WorldObject(activeX, activeY, "images/characterCards/characterCard2", 11)
    p1:setVisible(false)
    p2:setVisible(false)
    self:add()
end

function CharacterSwitchUI:update()
    if CharacterUIActive then
        if not p1:isVisible() then p1:setVisible(true) end
        if not p2:isVisible() then p2:setVisible(true) end

        updateScale += 0.3
        local updateSize = 1 + math.sin(updateScale) * 0.1
        if p1:getZIndex() == 11 then
            p1:setScale(updateSize, updateSize)
        elseif p2:getZIndex() == 11 then
            p2:setScale(updateSize, updateSize)
        end
    elseif not Switching then
        if p1:isVisible() then p1:setVisible(false) end
        if p2:isVisible() then p2:setVisible(false) end
        return
    end
    if not PlayerOneActive and p1:getZIndex() ~= 10 then
        p1:setZIndex(10)
        p2:setZIndex(11)
        p2:setScale(1.2, 1.2)

        CharacterSwitchUI:changePlaces()
    elseif PlayerOneActive and p2:getZIndex() ~= 10 then
        p2:setZIndex(10)
        p1:setZIndex(11)
        p1:setScale(1.2, 1.2)

        CharacterSwitchUI:changePlaces()
    end

    if co ~= nil then
        coroutine.resume(co)
    end
end

function CharacterSwitchUI:changePlaces()
    local function _f()
        local elapsed = 0
        local duration = 0.25

        local p1StartX, p1StartY = p1.x, p1.y
        local p1GoalX, p1GoalY

        if p1:getZIndex() == 10 then
            p1GoalX, p1GoalY = inactiveX, inactiveY
        else
            p1GoalX, p1GoalY = activeX, activeY
        end

        local p2StartX, p2StartY = p2.x, p2.y
        local p2GoalX, p2GoalY

        if p2:getZIndex() == 10 then
            p2GoalX, p2GoalY = inactiveX, inactiveY
        else
            p2GoalX, p2GoalY = activeX, activeY
        end

        while elapsed < duration do
            local time = elapsed / duration
            p1:moveTo(pd.math.lerp(p1StartX, p1GoalX, time), pd.math.lerp(p1StartY, p1GoalY, time))
            p2:moveTo(pd.math.lerp(p2StartX, p2GoalX, time), pd.math.lerp(p2StartY, p2GoalY, time))
            elapsed += Delta
            coroutine.yield()
        end

        p1:moveTo(p1GoalX, p1GoalY)
        p2:moveTo(p2GoalX, p2GoalY)

        p1:setScale(1, 1)
        p2:setScale(1, 1)
        Switching = false
    end

    co = coroutine.create(_f)
end
