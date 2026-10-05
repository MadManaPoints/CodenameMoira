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

local startX, startY = 0, 0   -- to store initial position
local playerX, playerY = 0, 0 -- track player position
local lineX, lineY = 0, 0     -- target for final point
local goalX, goalY

local totalPoints      -- total number of verlet points created
local updateX = 0      -- to update sine wave
local num, pnum = 1, 1 -- num and previous number of verlet points to track changes

local launch = false
local distToTarget, distPerStep -- distance from player to point

local casting = false           -- starts coroutine to move and create points
local reeling = false           -- true when player is latched on to target
local castX, castY = 0, 0

local co = nil -- coroutine

local pointDistance = 15

local testing = false


class('Verlet').extends(gfx.sprite)

function Verlet:init(x, y, _goalX, _goalY, isGrapple)
    startX, startY, playerX, playerY, lineX, lineY = x, y, x, y, x, y
    goalX, goalY = _goalX, _goalY
    self:moveTo(200, 120)
    self:setSize(400, 240)
    self.isGrapple = isGrapple
    self:setZIndex(4)
    gfx.setLineWidth(3)
    gfx.setLineCapStyle(gfx.kLineCapStyleRound)
    self:add()
end

function Verlet:reset()
    casting = false
    reeling = false

    for point in ipairs(verletPoints) do
        verletPoints[point] = nil
    end

    self:remove()
end

function Verlet:update()
    if Manny == nil and not testing then return end

    if Manny ~= nil then
        playerX, playerY = Manny.x, Manny.y
    else
        startX, startY = playerX, playerY
        -- Move Guy (*TESTING ONLY*) --
        if not casting then
            if pd.buttonIsPressed('Left') then
                playerX -= 2
            end

            if pd.buttonIsPressed('Right') then
                playerX += 2
            end

            if pd.buttonIsPressed('Up') then
                playerY -= 2
            end

            if pd.buttonIsPressed('Down') then
                playerY += 2
            end
        end
    end

    if co ~= nil then
        coroutine.resume(co) -- Update coroutine if it exists
    end

    if not casting and not reeling then
        if pd.buttonJustPressed('A') or Manny ~= nil then
            print("CAST")
            -- Start coroutine
            self:castLine(playerX, playerY, goalX, goalY)
            casting = true
        end
    end

    if not reeling then return end -- continue only when cast has reached its target

    local _dx = lineX - playerX
    local _dy = lineY - playerY

    -- get distance between target and player
    local _dist = math.sqrt(_dx * _dx + _dy * _dy)

    --idk why 15 works, but it gave me the best results
    distToTarget = _dist / pointDistance

    --print(math.floor(distToTarget + 0.5))

    -- total number of points based on distance to target
    local numberOfPoints = 0
    if self.isGrapple then
        numberOfPoints = math.max(math.max(2, math.floor(distToTarget + 0.5)), math.min(2, totalPoints))
    else
        numberOfPoints = math.max(math.max(2, math.floor(distToTarget + 0.5)), math.max(2, totalPoints))
    end
    print("#: " .. numberOfPoints .. "  |  " .. "Verlet: " .. #verletPoints)

    -- Add or remove points
    if #verletPoints > numberOfPoints then
        table.remove(verletPoints, #verletPoints)
    elseif #verletPoints ~= numberOfPoints then
        if #verletPoints == 0 then
            addPoint(goalX, goalY)
        else
            addPoint(verletPoints[#verletPoints].x, verletPoints[#verletPoints].y)
        end
    end

    -- Movement test
    --updateX += 0.1
end

function Verlet:draw(x, y, width, height)
    if Manny == nil and not testing then return end
    x, y = 0, 0
    width, height = 400, 240
    --gfx.setLineWidth(1)
    gfx.setColor(gfx.kColorBlack)

    if Manny == nil then
        gfx.fillCircleAtPoint(playerX, playerY, 10)
        gfx.drawCircleAtPoint(goalX, goalY, 5)
    end
    -- Connect first point to player
    if #verletPoints > 0 then
        gfx.drawLine(playerX, playerY, verletPoints[1].x, verletPoints[1].y)
    end

    -- Only draw if there are two or more points present
    if #verletPoints < 2 then return end

    -- First pin (player)
    verletPoints[1].x, verletPoints[1].y = playerX, playerY

    -- Second pin (rishing rod)
    -- N/A

    -- Last pin (target)

    --if self.isGrapple then
    --    verletPoints[#verletPoints].x, verletPoints[#verletPoints].y = goalX, goalY
    --else
    verletPoints[#verletPoints].x, verletPoints[#verletPoints].y = lineX, lineY
    --end

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
        gfx.drawLine(verletPoints[#verletPoints].x, verletPoints[#verletPoints].y, goalX, goalY)
    end

    gfx.setColor(gfx.kColorWhite)
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
    p.ax = -0.01
    p.ay = -0.1
    -- to simulate gravity
end

function Verlet:resolveDistance(p1, p2, targetDist)
    -- fetch distance between points
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local stiffness = 1
    local dist = math.sqrt(dx * dx + dy * dy) * stiffness

    -- prevent division by zero if points overlap
    if dist < 1e-6 then return end

    -- calculate unit vectors
    local nx = dx / dist
    local ny = dy / dist

    -- apply displacement evenly between two points
    local diff = dist - targetDist
    local offlineX = nx * diff * 0.5
    local offlineY = ny * diff * 0.5

    -- distribute displacement
    p1.x += offlineX
    p1.y += offlineY
    p2.x -= offlineX
    p2.y -= offlineY
end

function Verlet:castLine(x1, y1, x2, y2)
    local function moveToTarget()
        --if Manny ~= nil then Manny.playerControl = false end
        local elapsed = 0
        local pointDist = 5
        local endX, endY = x2, y2
        local duration = 0.4

        local _dx = endX - startX
        local _dy = endY - startY

        local _dist = math.sqrt(_dx * _dx + _dy * _dy)
        distToTarget = _dist / pointDistance
        distPerStep = math.floor(distToTarget + 0.5)

        local closeProximityOffset = 0

        if self.isGrapple then
            if distPerStep < 2 then
                closeProximityOffset = 2

                for i = 1, 2 do
                    addPoint(goalX, goalY) -- prevent weird offset when player is too close to goal
                end
            else
                for i = 2, distPerStep do
                    addPoint(playerX, playerY)
                end
            end

            totalPoints = distPerStep + closeProximityOffset
        else
            totalPoints = 1
            distToTarget = 0
            duration = 0
        end

        while elapsed < duration do
            local time = elapsed / duration
            lineX = pd.math.lerp(startX, endX, time)
            lineY = pd.math.lerp(startY, endY, time)
            elapsed += Delta
            coroutine.yield()
        end

        lineX, lineY = endX, endY

        reeling = true
        casting = false

        if Manny ~= nil and self.isGrapple then Manny.reeling = true end
    end

    co = coroutine.create(moveToTarget)
end
