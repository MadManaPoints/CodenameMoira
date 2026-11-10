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

local enterTop, enterBottom = 6, 234

local room = nil

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
    self:add()
end

function Canoe:update()
    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank)
    local change, acceleratedChange = pd.getCrankChange()

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

    local rot = self:getRotation()

    local gravityX, gravityY, gravityZ = pd.readAccelerometer()

    gfx.setDrawOffset(-self.x + 200, -self.y + 120) -- 'Camera' to follow player

    -- Flip player and background based on Playdate orientation
    if gravityY <= -0.5 and not upsideDown and gravityZ < 0.6 then
        upsideDown = true
        self:moveTo(400 - self.x, 240 - self.y)
        room:moveTo(400 - room.x, 240 - room.y)
        room:setRotation(room:getRotation() + 180)
        self:setRotation(self:getRotation() + 180)
    elseif gravityY >= 0.5 and upsideDown and gravityZ < 0.6 then
        upsideDown = false
        self:moveTo(400 - self.x, 240 - self.y)
        room:moveTo(400 - room.x, 240 - room.y)
        room:setRotation(room:getRotation() + 180)
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

    --Canoe:switchRooms(self.x, self.y)

    -- DEBUG --
    --if timer.timeout then
    --timer.timeout = false
    --print("X: ", gravityX, "  |  ", "Y: ", gravityY)
    --timer.targetTime = pd.getElapsedTime() + timer.totalTime
    --end
end

function Canoe:getRoom(_room)
    room = _room
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
