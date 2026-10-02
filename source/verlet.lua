-- VERLET INTEGRATION TESTING ZONE --
-- Source: https://www.lexaloffle.com/bbs/?tid=154658
--[[ This script was made with a ton of help from the above post. Credit to jonckjunior]] --

local pd <const> = playdate
local gfx <const> = pd.graphics
local geo <const> = pd.geometry

Verlet = {}

-- Dict to hold all verlet points
local verletPoints = {}

-- Creates new verlet points
local function addPoint(x, y)
    -- Make new dict
    local p =
    {
        -- Current position
        x = x,
        y = y,

        -- Previous position
        px = x,
        py = y,

        -- Simiulated acceleration
        ax = 0,
        ay = 0
    }

    table.insert(verletPoints, p)
end


local _x, _y = 200, 80        -- position to follow
local startX, startY = _x, _y -- to store initial position

local guyX, guyY = _x, _y
local totalPoints      -- total number of verlet points created
local updateX = 0      -- to update sine wave
local num, pnum = 1, 1 -- num and previous number of verlet points to track changes

local launch = false
local targetX, targetY = 0, 0   -- target for final point
local distToTarget, distPerStep -- distance from player to point

local casting = false           -- starts coroutine to move and create points
local reeling = false           -- true when player is latched on to target
local castX, castY = 0, 0

local co = nil -- coroutine

local test = false

local pointDistance = 15


class('Verlet').extends(gfx.sprite)

function Verlet:init(x, y)
    self:moveTo(200, 120)
    self:setSize(400, 240)
    gfx.setLineWidth(3)
    gfx.setLineCapStyle(gfx.kLineCapStyleRound)
    self:add()
end

function Verlet:update()
    -- Move Guy --
    if pd.buttonIsPressed('Left') then
        guyX -= 2
    end

    if pd.buttonIsPressed('Right') then
        guyX += 2
    end

    if pd.buttonIsPressed('Up') then
        guyY -= 2
    end

    if pd.buttonIsPressed('Down') then
        guyY += 2
    end

    --print(self:getSize())
    if co ~= nil then
        coroutine.resume(co) -- Update coroutine if it exists
    end

    if not casting and not reeling then
        if pd.buttonJustPressed('A') then
            -- Start coroutine
            self:castLine(200, 80, 350, 200)
            casting = true
        end
    end

    if not reeling then return end -- continue only when cast has reached its target

    if pd.buttonJustPressed('A') then
        test = true
    end

    local _dx = _x - guyX
    local _dy = _y - guyY

    -- get distance between target and player
    local _dist = math.sqrt(_dx * _dx + _dy * _dy)

    --idk why 15 works, but it gave me the best results
    distToTarget = _dist / pointDistance

    -- total number of points based on distance to target
    local numberOfPoints = math.min(math.max(2, math.floor(distToTarget + 0.5)), totalPoints)
    --print(numberOfPoints)

    -- Add or remove points
    if #verletPoints > numberOfPoints then
        table.remove(verletPoints, #verletPoints)
    elseif #verletPoints < numberOfPoints then
        addPoint(verletPoints[#verletPoints].x, verletPoints[#verletPoints].y)
    end

    -- Movement test
    --updateX += 0.1
end

function Verlet:draw(x, y, width, height)
    x, y = 0, 0
    width, height = 400, 240
    --gfx.setLineWidth(1)

    --gfx.fillCircleAtPoint(guyX, guyY, 10)

    -- Connect first point to player
    if #verletPoints > 0 then
        gfx.drawLine(guyX, guyY, verletPoints[1].x, verletPoints[1].y)
    end

    -- Only draw if there are two or more points present
    if #verletPoints < 2 then return end

    -- First pin (player)
    if not test then
        verletPoints[1].x, verletPoints[1].y = 200, 80
    else
        verletPoints[1].x, verletPoints[1].y = guyX, guyY
    end

    -- Second pin (rishing rod)
    -- N/A

    -- Last pin (target)
    verletPoints[#verletPoints].x, verletPoints[#verletPoints].y = _x, _y
    --print(verletPoints[#verletPoints].x .. "  " .. verletPoints[#verletPoints].y)

    for i = 1, #verletPoints do
        self:updateVerlet(verletPoints[i])

        if i < #verletPoints then
            self:resolveDistance(verletPoints[i], verletPoints[i + 1], 1)
        end
    end

    for i = 1, #verletPoints do
        if i < #verletPoints then
            gfx.drawLine(verletPoints[i].x, verletPoints[i].y, verletPoints[i + 1].x, verletPoints[i + 1].y)
        end
    end

    if reeling then
        gfx.drawLine(verletPoints[#verletPoints].x, verletPoints[#verletPoints].y, _x, _y)
    end
end

function Verlet:updateVerlet(p)
    -- calculate velocity implicitly
    local vx = p.x - p.px
    local vy = p.y - p.py

    -- update previous position to current
    p.px = p.x
    p.py = p.y

    -- calculate new position
    p.x += vx * 0.99 + p.ax
    p.y += vy * 0.99 + p.ay

    -- reset acceleration
    p.ax = 0
    p.ay = -0.1
    -- to simulate gravity
end

function Verlet:resolveDistance(p1, p2, targetDist)
    -- fetch distance between points
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local stiffness = 0.1
    local dist = math.sqrt(dx * dx + dy * dy) * stiffness

    -- prevent division by zero if points overlap
    if dist < 1e-6 then return end

    -- calculate unit vectors
    local nx = dx / dist
    local ny = dy / dist

    -- apply displacement evenly between two points
    local diff = dist - targetDist
    local off_x = nx * diff * 0.5
    local off_y = ny * diff * 0.5

    -- distribute displacement
    p1.x += off_x
    p1.y += off_y
    p2.x -= off_x
    p2.y -= off_y
end

function Verlet:castLine(x1, y1, x2, y2)
    local function moveToTarget()
        local elapsed = 0
        local pointDist = 5
        local endX, endY = x2, y2
        local duration = 0.6

        local _dx = endX - startX
        local _dy = endY - startY

        local _dist = math.sqrt(_dx * _dx + _dy * _dy)
        distToTarget = _dist / pointDistance
        distPerStep = math.floor(distToTarget + 0.5)

        for i = 1, distPerStep do
            addPoint(_x, _y)
        end

        totalPoints = distPerStep

        while elapsed < duration do
            local time = elapsed / duration
            _x = pd.math.lerp(startX, endX, time)
            _y = pd.math.lerp(startY, endY, time)
            elapsed += Delta
            coroutine.yield()
        end

        _x, _y = endX, endY
        --print(#verletPoints)

        reeling = true
        casting = false
    end

    co = coroutine.create(moveToTarget)
end
