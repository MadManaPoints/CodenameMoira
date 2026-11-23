local pd <const> = playdate
local gfx <const> = pd.graphics

-- from API
local function clamp(value, min, max)
    return math.max(math.min(value, max), min)
end

local ticksPerRevolution = 1
local crankMargin = 10
local upsideDown = false
local flipCheck = false

local velocity, drag = 0, 0.005
local dx, dy = 0, 0
local timer = Timer(1)

local enterTop, enterBottom = 6, 234

local camThresholdTop, camThresholdBottom = -240, 200
local flippedCamThresholdTop, flippedCamThresholdBottom = 480, 40

local outOfBoundsX, outOfBoundsY = false, false

local y_target, y_prevTarget

local offsetCheck = false


Canoe = {}

class('Canoe').extends(gfx.sprite)

function Canoe:init(x, y)
    self:setCenter(0.5, 0.5)
    local canoeSprite = gfx.image.new("images/canoe")
    self:setImage(canoeSprite)
    self:setCollideRect(0, 0, self:getSize())
    self:setCollidesWithGroups({ 1, 2, 3, 6 }) -- Same as player
    self:setGroups(2)
    self:setZIndex(0)
    self:moveTo(x, y)
    y_target, y_prevTarget = -camThresholdBottom + 120, -camThresholdBottom + 120
    self.room = nil
    self.roomObjects = { self:getRoomObjects() }
    self:add()
end

function Canoe:update()
    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank)
    local change, acceleratedChange = pd.getCrankChange()

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

    local rot = self:getRotation()

    local gravityX, gravityY, gravityZ = pd.readAccelerometer()

    --gfx.setDrawOffset(-self.x + 200, -self.y + 120) -- 'Camera' to follow player
    local y_pos = self.y

    -- Update horizontal boundaries
    if self.x < 60 or self.x > 340 then
        outOfBoundsX = true
    elseif outOfBoundsX then
        outOfBoundsX = false
    end

    if upsideDown then
        -- Update cam follow
        if self.y < flippedCamThresholdBottom then
            y_pos = flippedCamThresholdBottom
        elseif self.y > flippedCamThresholdTop then
            y_pos = flippedCamThresholdTop
        end

        -- Update vertical boundaries based on map orientation
        if self.y < -60 or self.y > 560 then
            outOfBoundsY = true
        elseif outOfBoundsY then
            outOfBoundsY = false
        end
    else
        -- Update cam follow
        if self.y > camThresholdBottom then
            y_pos = camThresholdBottom
        elseif self.y < camThresholdTop then
            y_pos = camThresholdTop
        end

        -- Update vertical boundaries based on map orientation
        if self.y > 300 or self.y < -320 then
            outOfBoundsY = true
        elseif outOfBoundsY then
            outOfBoundsY = false
        end
    end

    -- Push player toward center if they go out of bounds
    if outOfBoundsX then
        local direction = 200 - self.x
        if direction > 0 then self:moveBy(3, 0) end
        if direction < 0 then self:moveBy(-3, 0) end
    end

    if outOfBoundsY then
        if self.y > 0 then self:moveBy(0, -3) end
        if self.y < 0 then self:moveBy(0, 3) end
    end

    if upsideDown and not flipCheck then
        gfx.setDrawOffset(0, -y_pos + 120) -- Snap cam offset when flipping
        y_prevTarget = -y_pos + 120
        flipCheck = true
    elseif not upsideDown and flipCheck then
        gfx.setDrawOffset(0, -y_pos + 120) -- Snap cam offset when flipping back
        y_prevTarget = -y_pos + 120
        flipCheck = false
    else
        y_target = -y_pos + 120
        if y_prevTarget ~= y_target then
            y_prevTarget = pd.math.lerp(y_prevTarget, y_target, 0.1) -- Lerp cam to position to prevent camera jitter
        end

        gfx.setDrawOffset(0, y_prevTarget) -- Vertical cam follow
    end

    -- Flip player, background and all room objects based on Playdate orientation
    if gravityY <= -0.7 and not upsideDown then
        upsideDown = true
        self:moveTo(400 - self.x, 240 - self.y)
        self.room:moveTo(400 - self.room.x, 240 - self.room.y)
        self.room:setRotation(180)
        self:setRotation(self:getRotation() + 180)
        for i = 1, #self.roomObjects do
            self.roomObjects[i]:moveTo(400 - self.roomObjects[i].x, 240 - self.roomObjects[i].y)
            self.roomObjects[i]:setRotation(180)
        end
    elseif gravityY >= 0.7 and upsideDown then
        upsideDown = false
        self:moveTo(400 - self.x, 240 - self.y)
        self.room:moveTo(400 - self.room.x, 240 - self.room.y)
        self.room:setRotation(0)
        self:setRotation(self:getRotation() + 180)
        for i = 1, #self.roomObjects do
            self.roomObjects[i]:moveTo(400 - self.roomObjects[i].x, 240 - self.roomObjects[i].y)
            self.roomObjects[i]:setRotation(0)
        end
    end

    local goalX, goalY = self.x, self.y

    --Source: https://love2d.org/forums/viewtopic.php?t=5323
    dx = (math.sin(math.rad(rot)) * velocity)
    dy = (math.cos(math.rad(rot)) * velocity)

    -- Add movement to target positions
    goalX += dx
    goalY -= dy

    -- Apply drag
    if velocity > 0 then
        velocity -= drag
    else
        velocity = 0
    end

    -- ROTATE PLAYER BASED ON CRANK MOVEMENT (AND ORIENTATION) --

    --(upright)--
    if not upsideDown and change > 20 and crankTicks == 1 then
        velocity = 1.2
        self:setRotation(self:getRotation() - change * 0.2)
    end

    --(upside down)--
    if upsideDown and change < -20 and crankTicks == -1 then
        velocity = 1.2
        self:setRotation(self:getRotation() - change * 0.2)
    end

    ---- MOVE PLAYER ----
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

    for i = 1, #collisions do
        local col = collisions[i]
        local colSP = col.other

        -- Check if canoe is colliding with an obstacle on the water
        if colSP:isa(WaterObstacle) then
            local x, y = colSP.x, colSP.y                           -- Get position of obstacle
            local directionX, directionY = x - self.x, y - self.y   -- Get direction to obstacle
            local pushX = directionX > 0 and -1 or 1
            local pushY = directionY > 0 and -1 or 1                -- Push away from direction
            self:moveWithCollisions(self.x + pushX, self.y + pushY) -- Apply push
        end
    end
end

function Canoe:getRoom(_room)
    self.room = _room
end

function Canoe:getRoomObjects()
    local function exit()                                                           -- Called after minigame dialogue in canoe
        GAME_MANAGER:switchScene(Room(21, "images/rooms/canoeing/room4", nil, nil)) -- Fishing minigame
        gfx.setDrawOffset(0, 0)                                                     -- Reset 'camera'
        local fishing = Fishing()
    end

    local minigameTrigger = DialogueTrigger
        (
            200, -300, 20, 20, "This looks like a good spot.", false, false, exit
        )

    --local obstacle1 = WaterObstacle(100, 100, 20, 20)
    --local fish = AnimatedObject(110, 110, "images/fishingSpotAnim/fishingSpot")

    local obstacle1 = WaterObstacle(170, -60, 73, 90)

    local fish = AnimatedObject(210, -290, "images/fishingSpotAnim/fishingSpot")

    return minigameTrigger, obstacle1, fish
end

function Canoe:collisionResponse(other)
    if other:isa(Trigger) then
        return 'overlap'
    end
end

-- Probably not using this version
function Canoe:switchRooms(x, y)
    if y < 0 then
        for k, r in pairs(Trackers.day.day1.canoeing) do
            if r.id == RoomID then
                GAME_MANAGER:canoeSwitch
                (
                    Room(r.up, "images/rooms/canoeing/room" .. tostring(r.up)), x, enterBottom
                )
                break
            end
        end
    end

    if y > 240 then
        for k, r in pairs(Trackers.day.day1.canoeing) do
            if r.id == RoomID then
                GAME_MANAGER:canoeSwitch
                (
                    Room(r.down, "images/rooms/canoeing/room" .. tostring(r.down)), x, enterTop
                )
                break
            end
        end
    end
end
