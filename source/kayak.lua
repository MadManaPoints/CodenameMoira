local pd <const> = playdate
local gfx <const> = pd.graphics

-- from API
local function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

local ticksPerRevolution = 1
local crankMargin = 10
local upsideDown = false

local velocity, drag = 0, 0.005
local dx, dy = 0, 0
local timer = Timer(1)

Kayak = {}

class('Kayak').extends(gfx.sprite)

function Kayak:init(x, y)
    self:setCenter(0.5, 0.5)
    local kayakSprite = gfx.image.new("images/kayak")
    self:setImage(kayakSprite)
    self:setCollideRect(0, 0, self:getSize())
    self:setZIndex(0)
    self:moveTo(x, y)
    self:add()
end

function Kayak:update()
    --print(self:getRotation())
    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank)
    local change, acceleratedChange = pd.getCrankChange()

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

    local rot = self:getRotation()

    local gravityX, gravityY, gravityZ = pd.readAccelerometer()

    --gfx.setDrawOffset(self.x - 200, self.y - 120)

    if gravityY <= -0.5 and not upsideDown and gravityZ < 0.6 then
        upsideDown = true
        self:moveTo(400 - self.x, 240 - self.y)
        self:setRotation(self:getRotation() + 180)
    elseif gravityY >= 0.5 and upsideDown and gravityZ < 0.6 then
        upsideDown = false
        self:moveTo(400 - self.x, 240 - self.y)
        self:setRotation(self:getRotation() + 180)
    end

    local goalX, goalY = self.x, self.y

    --Source: https://love2d.org/forums/viewtopic.php?t=5323
    dx = (math.sin(math.rad(rot)) * velocity)
    dy = (math.cos(math.rad(rot)) * velocity)

    goalX += dx
    goalY -= dy

    if velocity > 0 then
        velocity -= drag
    else
        velocity = 0
    end

    if not upsideDown and change > 10 and crankTicks == 1 then
        velocity = 1
        self:setRotation(self:getRotation() - change * 0.27)
    end

    if upsideDown and change < -10 and crankTicks == -1 then
        velocity = 1
        self:setRotation(self:getRotation() - change * 0.27)
    end

    ---- MOVE PLAYER ----
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

    -- DEBUG --
    --if timer.timeout then
    --timer.timeout = false
    --print("X: ", gravityX, "  |  ", "Y: ", gravityY)
    --timer.targetTime = pd.getElapsedTime() + timer.totalTime
    --end
end
