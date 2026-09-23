local pd <const> = playdate
local gfx <const> = pd.graphics

P2 = {}

--- ABILITIES ---

-- Sword --
local sword = nil
local swordEquipped = false
local tornado = false

-- Broom --
local flyDir = { false, false, false, false }
local flyingTimer = Timer(0.25)
local flying = false
local canDismount = true

local speed = 3

local spriteSheet =
{
    femaleIdle = gfx.imagetable.new("images/femaleIdle/femaleIdle"),
    femaleWalk = gfx.imagetable.new("images/femaleWalk/femaleWalk"),
    femaleFlying = gfx.imagetable.new("images/flying/flying"),
    log = gfx.image.new("images/log"),
    sword = gfx.imagetable.new("images/swingAttack/swingAttack"),
}

local idleAnim = gfx.animation.loop.new(100, spriteSheet.femaleIdle, true)

local walkAnim =
{
    left = gfx.animation.loop.new(90, spriteSheet.femaleWalk, true),
    right = gfx.animation.loop.new(90, spriteSheet.femaleWalk, true),
    front = gfx.animation.loop.new(70, spriteSheet.femaleWalk, true),
    back = gfx.animation.loop.new(70, spriteSheet.femaleWalk, true),
}

walkAnim.left.startFrame = 1
walkAnim.left.endFrame = 4

walkAnim.right.startFrame = 5
walkAnim.right.endFrame = 8

walkAnim.front.startFrame = 9
walkAnim.front.endFrame = 12

walkAnim.back.startFrame = 13
walkAnim.back.endFrame = 16

local flyAnim =
{
    idle = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    right = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    left = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    front = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    back = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true)
}

flyAnim.right.startFrame = 1
flyAnim.right.endFrame = 2

flyAnim.left.startFrame = 7
flyAnim.left.endFrame = 8

flyAnim.front.startFrame = 3
flyAnim.front.endFrame = 4

flyAnim.back.startFrame = 5
flyAnim.back.endFrame = 6

local swordAnim =
{
    idle = gfx.animation.loop.new(100, spriteSheet.sword, false),
    spinSlowForward = gfx.animation.loop.new(160, spriteSheet.sword, true),
    spinFastForward = gfx.animation.loop.new(75, spriteSheet.sword, true),
    spinSlowReverse = gfx.animation.loop.new(160, spriteSheet.sword, true),
    spinFastReverse = gfx.animation.loop.new(75, spriteSheet.sword, true),
    tornado = gfx.animation.loop.new(120, spriteSheet.sword, true)
}

swordAnim.idle.startFrame = 11
swordAnim.idle.endFrame = 11

swordAnim.spinFastForward.startFrame = 2
swordAnim.spinFastForward.endFrame = 5
swordAnim.spinSlowForward.startFrame = 2
swordAnim.spinSlowForward.endFrame = 5

swordAnim.spinFastReverse.startFrame = 6
swordAnim.spinFastReverse.endFrame = 9
swordAnim.spinSlowReverse.startFrame = 6
swordAnim.spinSlowReverse.endFrame = 9

swordAnim.tornado.startFrame = 14
swordAnim.tornado.endFrame = 15

local states =
{
    idle = 1,
    walking = { left = 2, right = 3, front = 4, back = 5 },
    flying = { idle = 6, left = 7, right = 8, front = 9, back = 10 },
    sword = 11,
}

local state = states.idle


class('P2').extends(Player)

function P2:init(x, y, alone, isPlayerOne, currentDir, abilityOneEquipped)
    P2.super.init(self, x, y, alone, isPlayerOne, currentDir, abilityOneEquipped)
    --self:setCollideRect(17, 12, 13, 18) -- 48x48

    if abilityOneEquipped or abilityOneEquipped == nil then
        self.anim = swordAnim.idle
    else
        self.anim = flyAnim.left
    end

    self:setCollideRect(17, 12, 13, 18) -- 48x48
    self:add()
end

function P2:update()
    P2.super.update(self)
    --print(self.onTrigger)
end

function P2:abilityManager()
    self:flyingManager()
end

function P2:movement(_goalX, _goalY)
    -- set current direction to nil if no directional buttons are pressed
    if #self.heldDir == 0 and self.playerControl and not flying then
        if self.currentDir ~= nil then self.currentDir = nil end

        -- set most recent button pressed as current direction
    elseif self.currentDir ~= self.heldDir[#self.heldDir] then
        self.currentDir = self.heldDir[#self.heldDir]
    end

    if (not flying and self.currentDir == "up") or flyDir[1] then
        if not flying and state ~= states.sword then
            if state ~= states.walking.back then state = states.walking.back end
        elseif flying then
            if state ~= states.flying.back then state = states.flying.back end
        end
        _goalY -= speed
    elseif (not flying and self.currentDir == "down") or flyDir[2] then
        if not flying and state ~= states.sword then
            if state ~= states.walking.front then state = states.walking.front end
        elseif flying then
            if state ~= states.flying.front then state = states.flying.front end
        end
        _goalY += speed
    end

    if (not flying and self.currentDir == "left") or flyDir[3] then
        if not flying and state ~= states.sword then
            if state ~= states.walking.left then state = states.walking.left end
        elseif flying then
            if state ~= states.flying.left then state = states.flying.left end
        end
        _goalX -= speed
    elseif (not flying and self.currentDir == "right") or flyDir[4] then
        if not flying and state ~= states.sword then
            if state ~= states.walking.right then state = states.walking.right end
        elseif flying then
            if state ~= states.flying.right then state = states.flying.right end
        end
        _goalX += speed
    end

    if self.alone == nil then
        -- lerp following player behind current player
        if self.currentDir == "up" then
            self.prevY = pd.math.lerp(self.prevY, self.y + 16, 0.25)
            self.prevX = pd.math.lerp(self.prevX, self.x, 0.25)
        elseif self.currentDir == "down" then
            self.prevY = pd.math.lerp(self.prevY, self.y - 16, 0.25)
            self.prevX = pd.math.lerp(self.prevX, self.x, 0.25)
        end

        if self.currentDir == "left" then
            self.prevX = pd.math.lerp(self.prevX, self.x + 16, 0.25)
            self.prevY = pd.math.lerp(self.prevY, self.y, 0.25)
        elseif self.currentDir == "right" then
            self.prevX = pd.math.lerp(self.prevX, self.x - 16, 0.25)
            self.prevY = pd.math.lerp(self.prevY, self.y, 0.25)
        end
    end

    ---- MOVE CURRENT PLAYER ----
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(_goalX, _goalY)

    local clearOfWater = true
    if self.alone and flying then
        for i = 1, #collisions do
            local col = collisions[i]
            local colSP = col.other

            -- prevent player from exiting broom if on water
            if colSP:getTag() == 4 then
                if canDismount then canDismount = false end
                clearOfWater = false
            end
        end
    end

    -- allow dismount if clear of water
    if not canDismount and clearOfWater then
        canDismount = true
    end
end

function P2:followPartner(_goalX, _goalY)
    local goalX, goalY = Manny.prevX, Manny.prevY

    ---- MOVE FOLLOWING PLAYER ----
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
end

function P2:flyingManager()
    if flying then
        local gravityX, gravityY, gravityZ = pd.readAccelerometer()

        if gravityX > -0.2 and gravityX < 0.2 and gravityY > 0.18 and gravityY < 0.4 then
            for i = 1, #flyDir do
                if flyDir[i] then flyDir[i] = false end
            end
        end

        --move player up or down based on whether playdate is tilted forward or backward, respectively
        if gravityY <= 0.18 and not flyDir[1] then
            for i = 1, #flyDir do
                if flyDir[i] then flyDir[i] = false end
            end
            flyDir[1] = true
        elseif gravityY >= 0.4 and not flyDir[2] then
            for i = 1, #flyDir do
                if flyDir[i] then flyDir[i] = false end
            end
            flyDir[2] = true
        end

        --move player left or right based on whether playdate is tilted in respective direction
        if gravityX <= -0.2 and not flyDir[3] then
            for i = 1, #flyDir do
                if flyDir[i] then flyDir[i] = false end
            end
            flyDir[3] = true
        elseif gravityX >= 0.2 and not flyDir[4] then
            for i = 1, #flyDir do
                if flyDir[i] then flyDir[i] = false end
            end
            flyDir[4] = true
        end
    else
        -- ensure movement reverts to default when no longer flying
        for i = 1, #flyDir do
            if flyDir[i] then flyDir[i] = false end
        end
    end
end

function P2:fly()
    if not canDismount or self.tornado then return end

    if swordEquipped then
        swordEquipped = false
    end

    if not flying then
        --self:setCollideRect(5, 3, 13, 18)
        state = states.flying.right
        speed = 5
        flying = true
    end

    if self.ability1 then self.ability1 = false end
    if not self.ability2 then self.ability2 = true end
end

function P2:swordManager()
    if not canDismount and not self.ded then return end

    --add sword if there's no sword in the scene
    if sword == nil then
        sword = Sword(self.x, self.y)
    end

    if flying then
        speed = 3
        flying = false
    end

    -- turn sword on or off
    if state ~= states.sword then
        state = states.sword
    end

    swordEquipped = true
    if self.ability2 then self.ability2 = false end
    if not self.ability1 then self.ability1 = true end
end

function P2:abilityOne()
    self:swordManager()
end

function P2:abilityTwo()
    self:fly()
end

function P2:logCanoe()

end

function P2:logMinigame()
    sword = nil
    swordEquipped = false
    tornado = false

    flyDir = { false, false, false, false }
    flying = false
    canDismount = true

    speed = 3
end

function P2:animationManager()
    if state == states.sword then
        if sword.spin > 0 then
            -- If forward spin speed goes below threshold, end tornado animation
            if sword.spin < 4 then
                if self.tornado then
                    self.tornado = false                -- tracks when to turn off collision
                    swordAnim.spinSlowForward.frame = 1 -- reset slow forward spin animation
                end

                -- Set new animation back to spin
                if self.anim ~= swordAnim.spinSlowForward then self.anim = swordAnim.spinSlowForward end
            elseif sword.spin >= 4 then
                -- If forward spin speed goes above threshold, start tornado animation
                if not self.tornado then
                    self.tornado = true                 -- tracks when to apply collision
                    swordAnim.spinSlowForward.frame = 1 -- reset animation
                end

                -- Set tornado animation
                if self.anim ~= swordAnim.tornado then self.anim = swordAnim.tornado end
            end
        elseif sword.spin < 0 then
            -- If backward spin speed goes above threshold, end tornado animation
            if sword.spin > -4 then
                if self.tornado then
                    self.tornado = false                -- tracks when to turn off collision
                    swordAnim.spinSlowReverse.frame = 1 -- reset animation
                end

                -- Set animation back to spin
                if self.anim ~= swordAnim.spinSlowReverse then self.anim = swordAnim.spinSlowReverse end
            elseif sword.spin <= -4 then
                -- If backward spin goes below threshold, start tornado animation
                if not self.tornado then
                    self.tornado = true                 -- tracks when to apply collision
                    swordAnim.spinSlowReverse.frame = 1 -- reset animation
                end

                -- Set tornado animation
                if self.anim ~= swordAnim.tornado then self.anim = swordAnim.tornado end
            end
        elseif sword.speed == 0 then
            -- End spin animation and reset frames when spin speed returns to 0
            swordAnim.spinSlowForward.frame = 1
            swordAnim.spinSlowReverse.frame = 1

            if self.anim ~= swordAnim.idle then self.anim = swordAnim.idle end
            if self.tornado then
                self.tornado = false
            end
        end
    elseif state == states.walking.left then
        if self.anim ~= walkAnim.left then self.anim = walkAnim.left end
    elseif state == states.walking.right then
        if self.anim ~= walkAnim.right then self.anim = walkAnim.right end
    elseif state == states.walking.front then
        if self.anim ~= walkAnim.front then self.anim = walkAnim.front end
    elseif state == states.walking.back then
        if self.anim ~= walkAnim.back then self.anim = walkAnim.back end
    elseif state == states.idle then
        if self.anim ~= idleAnim then self.anim = idleAnim end
    elseif state == states.flying.right then
        if self.anim ~= flyAnim.right then self.anim = flyAnim.right end
    elseif state == states.flying.left then
        if self.anim ~= flyAnim.left then self.anim = flyAnim.left end
    elseif state == states.flying.front then
        if self.anim ~= flyAnim.front then self.anim = flyAnim.front end
    elseif state == states.flying.back then
        if self.anim ~= flyAnim.back then self.anim = flyAnim.back end
    end
end

function P2:roomCheck()
    if sword ~= nil then sword = nil end
end

function P2:collisionResponse(other)
    --P2.super.collisionResponse(self, other)
    if other:isa(Collider) then
        if other.isTrigger or (not self.playerControl and not self.onLog) or (other:isa(Water) and (flying or self.onLog)) then
            return 'overlap'
        elseif self.tornado and not other:isa(Water) then
            return 'bounce'
        else
            return 'freeze'
        end
    end

    if other:isa(Breakable) then
        if other.broken then
            return 'overlap'
        else
            return 'freeze'
        end
    end

    if other:isa(Enemy) then
        if not other.ded and not self.ded then
            other.x = other.startX
            other.y = other.startY
            self.ded = true
        end
        return 'overlap'
    end
end
