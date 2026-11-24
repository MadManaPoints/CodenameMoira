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
local flipTimer = nil

local velocity, drag <const> = 0, 0.005
local dx, dy = 0, 0
local timer = Timer(1)

local enterTop <const>, enterBottom <const> = 6, 234

local camThresholdTop <const>, camThresholdBottom <const> = -240, 200
local flippedCamThresholdTop <const>, flippedCamThresholdBottom <const> = 480, 40

local outOfBoundsX, outOfBoundsY = false, false

local y_target, y_prevTarget

local offsetCheck = false

local atTarget = false


Canoe = {}

class('Canoe').extends(gfx.sprite)

function Canoe:init(x, y)
    self:setCenter(0.5, 0.5)
    local canoeSprite = gfx.image.new("images/canoe")
    self:setImage(canoeSprite)
    self:setCollideRect(0, 0, self:getSize())
    self:setCollidesWithGroups({ 1, 2, 3, 6 }) -- Same as player
    self:setGroups(2)
    self:setZIndex(5)
    self:moveTo(x, y)
    y_target, y_prevTarget = -camThresholdBottom + 120, -camThresholdBottom + 120 -- Start at bottom of screen
    self.room = nil                                                               -- Fills after function call
    self.roomObjects = { self:getRoomObjects() }                                  -- Get all objects that need to be flipped

    self.offsets = {}                                                             -- Room object offsets
    for i = 0, #self.roomObjects - 2 do
        local offsetTable = self.roomObjects[#self.roomObjects]
        local getPosTable = { x = offsetTable[i + 1], y = offsetTable[#offsetTable - i] } -- Grab first and last elements and move inward
        table.insert(self.offsets, getPosTable)                                           -- Update offset table
    end

    DialogueY = -355

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
    if gravityY <= -0.7 and not upsideDown and not atTarget then
        upsideDown = true                                      -- Run block only once
        self:moveTo(400 - self.x, 240 - self.y)                -- Move player
        self.room:moveTo(400 - self.room.x, 240 - self.room.y) -- Move room bg
        self:setRotation(self:getRotation() + 180)             -- Flip player
        self.room:setRotation(180)                             -- Flip room bg

        for i = 1, #self.roomObjects - 1 do
            self.roomObjects[i]:moveTo -- Move room objects into flipped positions
            (
                400 - self.roomObjects[i].x - self.offsets[i]["x"],
                240 - self.roomObjects[i].y - self.offsets[i]["y"]
            )

            self.roomObjects[i]:setRotation(180) -- Flip room objects
        end
    elseif (atTarget or gravityY >= 0.7) and upsideDown then
        upsideDown = false                                     -- Run block only once
        self:moveTo(400 - self.x, 240 - self.y)                -- Move player
        self.room:moveTo(400 - self.room.x, 240 - self.room.y) -- Move room bg
        self:setRotation(self:getRotation() + 180)             -- Flip player
        self.room:setRotation(0)                               -- Flip room bg

        for i = 1, #self.roomObjects - 1 do
            self.roomObjects[i]:moveTo -- Move room objects into standard positions
            (
                400 - self.roomObjects[i].x - self.offsets[i]["x"],
                240 - self.roomObjects[i].y - self.offsets[i]["y"]
            )

            self.roomObjects[i]:setRotation(0) -- Flip room objects
        end
    end

    if atTarget and not upsideDown then
        local _x = pd.math.lerp(self.x, self.roomObjects[1].x + 10, 0.05)
        local _y = pd.math.lerp(self.y, self.roomObjects[1].y + 10, 0.05)
        self:moveTo(_x, _y)
        return
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
    if not upsideDown and change > 0 and crankTicks == 1 then
        velocity = 1.2
        self:setRotation(self:getRotation() - change * 0.3)
    end

    --(upside down)--
    if upsideDown and change < 0 and crankTicks == -1 then
        velocity = 1.2
        self:setRotation(self:getRotation() - change * 0.3)
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

        if colSP:isa(DialogueTrigger) then
            atTarget = true
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
        DialogueY = 5
        local fishing = Fishing()
    end

    local minigameTrigger = DialogueTrigger
        (
            200, -300, 20, 20, "This looks like a good spot.", false, false, exit
        )

    local obstacle1 = WaterObstacle(170, -60, 73, 90)                            -- Create collider for island
    local fish = AnimatedObject(210, -290, "images/fishingSpotAnim/fishingSpot") -- Add fishing spot animated sprite
    local offsets = { 20, 73, 0, 0, 90, 20 }                                     -- Offsets for realigning colliders when flipped

    return minigameTrigger, obstacle1, fish, offsets
end

function Canoe:collisionResponse(other)
    if other:isa(Trigger) then
        return 'overlap'
    end
end
