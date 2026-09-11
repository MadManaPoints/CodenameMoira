local pd <const> = playdate
local gfx <const> = pd.graphics

Enemy = {}

class('Enemy').extends(gfx.sprite)

local spriteSheet =
{
    swarm = gfx.imagetable.new("images/swarmAnim/swarmAnim")
}

local w = 16
local h = 10

local swarmStart = gfx.animation.loop.new(200, spriteSheet.swarm, false)
local swarmIdle = gfx.animation.loop.new(200, spriteSheet.swarm, true)

swarmStart.startFrame = 1
swarmStart.endFrame = 6

swarmIdle.startFrame = 7
swarmIdle.endFrame = 9

function Enemy:init(x, y, isSwarm, isMoving, id, ded)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self.startX = x
    self.startY = y
    self.swarm = isSwarm
    if not self.swarm then
        local img = gfx.image.new("images/monster")
        self:setImage(img)
        self:setCollideRect(15, 20, 18, 13)
    else
        self:setCollideRect(5, 3, 13, 18)
    end
    self.moving = isMoving
    self.anim = swarmStart
    self.ded = ded
    self.id = id
    self.updateTime = 0
    self.moveSpeed = 0.08
    self:setGroups(6)
    self:setCollidesWithGroups({ 1, 2, 7 })
    self:setTag(5)
    self:setZIndex(4)
    if ded ~= nil and ded then
        if isSwarm then
            -- Remove swarm if it's dead
            self:remove()
        else
            -- Add monster to coordinates where it died
            local newX = Trackers.night.night1.rooms["room" .. tostring(RoomID)].enemies["monster" .. tostring(id)].x
            local newY = Trackers.night.night1.rooms["room" .. tostring(RoomID)].enemies["monster" .. tostring(id)].y
            self:moveTo(newX, newY)
            self:add()
        end
    else
        self:add()
    end
end

local function map(value, minA, maxA, minB, maxB)
    local range = maxA - minA
    local valuePercent = (value - minA) / range

    local newRange = maxB - minB

    return valuePercent * newRange + minB
end

function Enemy:update()
    if self.swarm then
        if self.anim == swarmStart and self.anim.frame == swarmStart.endFrame then self.anim = swarmIdle end
        self:setImage(self.anim:image())

        if self.moving then
            self:move()
        end

        if self.ded then
            -- Set specific enemy to ded for scene persistence
            Trackers.night.night1.rooms["room" .. tostring(RoomID)].enemies[self.id] = true
            self:remove()
        end
    else
        if self.ded then
            if self:getRotation() ~= 180 then
                self:setRotation(180)
                -- Let tracker dictionary know the monster has died
                Trackers.night.night1.rooms["room" .. tostring(RoomID)].enemies["monster" .. tostring(self.id)][1] = true

                -- Store x and y positions when dead for scene consistency
                Trackers.night.night1.rooms["room" .. tostring(RoomID)]
                .enemies["monster" .. tostring(self.id)].x = self.x
                Trackers.night.night1.rooms["room" .. tostring(RoomID)]
                .enemies["monster" .. tostring(self.id)].y = self.y
            end

            return
        end

        -- **NOTE: I don't love having to map everything to the grid, but I'll leave it like this for now** --
        local x, y = math.floor(map(self.x, 0, 400, 1, 16)), math.floor(map(self.y, 0, 240, 1, 10))
        local targetX, targetY = math.floor(map(Tati.x, 0, 400, 1, 16)), math.floor(map(Tati.y, 0, 240, 1, 10))
        local startNode = P.graph:nodeWithXY(x, y)
        local endNode = P.graph:nodeWithXY(targetX, targetY)

        if endNode == nil then return end -- return if target doesn't exist
        local path = P.graph:findPath(startNode, endNode, nil)

        if path[2] ~= nil then
            local goalX, goalY = self.x, self.y

            -- Get direction to player
            local dirX, dirY = path[2].x * 25 - goalX, path[2].y * 24 - goalY
            local dirVector = pd.geometry.vector2D.new(dirX, dirY)

            -- Normalize vector, then round x and y for precision
            dirVector:normalize()
            dirVector.dx = math.floor(dirVector.dx + 0.5)
            dirVector.dy = math.floor(dirVector.dy + 0.5)

            -- Set direction and apply speed
            goalX += dirVector.dx * 1.2; goalY += dirVector.dy * 1.2

            -- Move toward player
            local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
        else
            -- Pathfinding sometimes stops just before reaching the player, so this gives them that last oomph in case they stop
            local goalX, goalY = self.x, self.y

            local newX = Tati.x - goalX
            local newY = Tati.y - goalY

            local xDir = newX > 0 and 1 or -1
            local yDir = newY > 0 and 1 or -1

            goalX += xDir * 1.2; goalY += yDir * 1.2

            local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
        end
    end
end

function Enemy:move()
    local goalX, goalY = self.x, self.y

    if self.swarm then
        goalY = self.startY + math.sin(self.updateTime) * 26
        self.updateTime += self.moveSpeed
        local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
    end
end

function Enemy:collisionResponse(other)
    return 'overlap'
end
