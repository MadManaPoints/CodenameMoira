local pd <const> = playdate
local gfx <const> = pd.graphics

local delta = 0.0

Sword = {}

class('Sword').extends(gfx.sprite)

function Sword:init(x, y)
    --self:setCenter(0.5, 0.5)
    self:setZIndex(0)
    local swordImg = gfx.image.new("images/sword2")
    self:setImage(swordImg)
    self:setCollideRect(-5, -13, 40, 40)
    self:moveTo(x, y)
    self:setTag(26)
    self:setCollidesWithGroups({ 3 })
    self:setGroups(4)

    self.realX = Tati.x
    self.realY = Tati.y
    self.rot = 0.0 -- not used anymore
    self.held = true

    -- get direction to move when thrown
    self.directionX = 0
    self.directionY = 0
    self.stuck = false
    self.speed = 0

    self.acceleration = 0.2

    -- track spin
    self.spin = 0

    --self:setUpdatesEnabled(false)
    self:add()
end

function Sword:update()
    delta = pd.getElapsedTime()
    pd.resetElapsedTime()

    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank)
    local change, acceleratedChange = pd.getCrankChange()
    -- the faster you turn the crank, the faster you spin
    local spinStrength = acceleratedChange * 2 * delta

    --print(change .. "  " .. acceleratedChange)
    --print(self.spin)

    if self.spin ~= 0 then
        -- balancing feedback loop to revert spin back to 0 over time
        -- for positive (clockwise) spin
        if self.spin > 0.1 then
            self.spin -= delta * 10.0
        elseif self.spin > 0 and self.spin < 0.1 then
            self.spin = 0
        end

        -- for negative (anticlockwise) spin
        if self.spin < -0.1 then
            self.spin += delta * 10.0
        elseif self.spin > -0.1 and self.spin < 0 then
            self.spin = 0
        end
    end

    -- calculate spin based on crank speed
    if acceleratedChange > 20 or acceleratedChange < -20 then
        self.spin += spinStrength * delta * 3.0
    end

    -- clamp positive spin number
    if self.spin > 60.0 then
        self.spin = 60.0
    end

    -- clamp negative spin number
    if self.spin < -60.0 then
        self.spin = -60.0
    end

    -- get player position as target position
    local goalX, goalY = Tati.x, Tati.y

    -- rotate basesd on spin when held
    if self.held then
        --Tati:setRotation(Tati:getRotation() + self.spin)
        --print(self.spin)
    end

    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

    if self.held then
        -- map throw speed to spin strength
        self.speed = Sword:map(self.spin, -60, 60, -15, 15)
    end
end

function Sword:collisionResponse(other)
    if other:isa(Player) then
        return 'overlap'
    end

    if other:isa(Collider) then
        if self.held then
            return 'overlap'
        else
            self.stuck = true
            return 'freeze'
        end
    end

    if other:isa(Breakable) then
        if Tati.tornado and not other.broken then
            other.broken = true
        end

        return 'overlap'
    end
end

function Sword:map(value, minA, maxA, minB, maxB)
    local range = maxA - minA;
    local valuePercent = (value - minA) / range;

    local newRange = maxB - minB;

    return valuePercent * newRange + minB;
end
