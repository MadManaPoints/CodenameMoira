local pd <const> = playdate
local gfx <const> = pd.graphics

P1 = {}

local speed = 3

local spriteSheet =
{
    maleIdle = gfx.imagetable.new("images/maleIdle/maleIdle"),
    maleWalk = gfx.imagetable.new("images/maleWalk/maleWalk"),
    malePole = gfx.image.new("images/malePole/fishingPole"),
    log = gfx.image.new("images/log"),
    jump = gfx.imagetable.new("images/malePole/jump/fishpoleJump"),
    spray = gfx.imagetable.new("images/spray/spray"),
}

local idleAnim = gfx.animation.loop.new(150, spriteSheet.maleIdle, true)

local walkAnim =
{
    left = gfx.animation.loop.new(90, spriteSheet.maleWalk, true),
    right = gfx.animation.loop.new(90, spriteSheet.maleWalk, true),
    front = gfx.animation.loop.new(70, spriteSheet.maleWalk, true),
    back = gfx.animation.loop.new(70, spriteSheet.maleWalk, true)
}

walkAnim.left.startFrame = 1
walkAnim.left.endFrame = 4

walkAnim.right.startFrame = 5
walkAnim.right.endFrame = 8

walkAnim.front.startFrame = 9
walkAnim.front.endFrame = 12

walkAnim.back.startFrame = 13
walkAnim.back.endFrame = 16

local swingAnim = nil

local jumpAnim =
{
    firstPos = gfx.animation.loop.new(150, spriteSheet.jump, false),
    secondPos = gfx.animation.loop.new(150, spriteSheet.jump, false),
    whoosh = gfx.animation.loop.new(80, spriteSheet.jump, false),
    jump = gfx.animation.loop.new(200, spriteSheet.jump, false)
}

jumpAnim.repeatCount = 1

jumpAnim.firstPos.startFrame = 1
jumpAnim.firstPos.endFrame = 1

jumpAnim.secondPos.startFrame = 2
jumpAnim.secondPos.endFrame = 2

jumpAnim.whoosh.startFrame = 3
jumpAnim.whoosh.endFrame = 5

jumpAnim.jump.startFrame = 6
jumpAnim.jump.endFrame = 10

local states =
{
    idle = 1,
    walking = { left = 2, right = 3, front = 4, back = 5 },
    climbing = 6,
    spraying = 7,
    swinging = 8,
    pulling = 9,
    logPulling = 10
}

local state = states.idle

-- ABILITIES ---

-- Fishing Pole --
local canUsePole = false
local stumpX, minClimbRange, maxClimbRange = 0, 0, 0
local isSwinging = false
local castTimer = Timer(0.5)
local reeling = false
local canCast = false
local reelCastPosition = -0.7
local reelCastThreshold = 1.5
local prevZ = 0
local castPosition = -0.7
local logIndex = 1
local logDirections = { 3, 0, 0, 0, 3, 90, -3, 0, 0, 0, -3, 90 } -- temp

-- Bug Spray --
local spray = nil
local isSpraying = false
local sprayTimer = Timer(.75)


class('P1').extends(Player)

function P1:init(x, y, alone, isPlayerOne)
    P1.super.init(self, x, y, alone, isPlayerOne)
    self.swingTargetTracker = 0

    self.anim = idleAnim -- set start animation
end

function P1:update()
    P1.super.update(self)
end

function P1:movement(_goalX, _goalY)
    -- set current direction to nil if no directional buttons are pressed
    if #self.heldDir == 0 and self.playerControl then
        if self.currentDir ~= nil then self.currentDir = nil end

        -- set most recent button pressed as current direction
    elseif self.currentDir ~= self.heldDir[#self.heldDir] then
        self.currentDir = self.heldDir[#self.heldDir]
    end

    if self.currentDir == "up" then
        if state ~= states.walking.back then state = states.walking.back end
        if isSpraying then spray:changeDirection(self.x, self.y - 20) end

        _goalY -= speed
    elseif self.currentDir == "down" then
        if state ~= states.walking.front then state = states.walking.front end
        if isSpraying then spray:changeDirection(self.x, self.y + 20) end
        _goalY += speed
    end

    if self.currentDir == "left" then
        if state ~= states.walking.left then state = states.walking.left end
        if isSpraying then spray:changeDirection(self.x - 18, self.y) end
        _goalX -= speed
    elseif self.currentDir == "right" then
        if state ~= states.walking.right then state = states.walking.right end
        if isSpraying then spray:changeDirection(self.x + 18, self.y) end
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
end

function P1:followParnter(_goalX, _goalY)
    local goalX, goalY = Manny.prevX, Manny.prevY

    ---- MOVE FOLLOWING PLAYER ----
    local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
end

function P1:abilityManager()
    self:climbManager()
    self:sprayManager()
    self:swingManager()
    self:logFishing()
end

function P1:climbManager()
    if self.ability2 then
        if state ~= states.climbing and pd.buttonJustPressed("A") then
            if not self.onTrigger then return end
            if isSpraying then self:bugSpray() end
            local info = self.triggerInfo
            print(info[1])
            self.playerControl = false
            self:changeState(6, info[1] + 10, self.y, info[3])
            return
        end
        if state == states.climbing then
            local x = pd.math.lerp(self.x, stumpX, 0.25)
            self:moveTo(x, self.y)
            local change, acceleratedChange = pd.getCrankChange()
            if self.y > minClimbRange then
                if change > 30 then
                    self:moveBy(0, -1)
                end
            else
                self.y = minClimbRange
            end

            if self.y == minClimbRange then
                if pd.buttonJustPressed("A") then
                    self.playerControl = true
                    state = states.idle
                end
            end

            if self.y < maxClimbRange then
                if change < -30 then
                    self:moveBy(0, 1)
                end
            else
                self.y = maxClimbRange
            end

            if self.y == maxClimbRange then
                if pd.buttonJustPressed("A") then
                    self.playerControl = true
                    state = states.idle
                end
            end
        end
    end
end

function P1:swingManager()
    if self.ability2 and pd.buttonJustPressed("A") and self.onTrigger and self.triggerInfo[4] and state ~= states.swinging then
        self.anim = jumpAnim.firstPos
        self.playerControl = false
        state = states.swinging
    elseif state == states.swinging and pd.buttonJustReleased("A") and not reeling then
        state = states.idle
        self.playerControl = true
        canCast = false
    end

    if state == states.swinging and not reeling then
        local gravityX, gravityY, gravityZ = pd.readAccelerometer()
        local castStrength = math.abs(gravityZ - prevZ)

        -- check if playdate is pulled back (correct position)
        if gravityZ < reelCastPosition then
            -- allow casting
            if not canCast then
                canCast = true
                self.anim = jumpAnim.secondPos
                print("SEND IT, DAWG")
            end


            -- reset timer for buffer check
            if castTimer.startTimer then
                castTimer.startTimer = false
                castTimer.timeout = false
            end
            -- check if playdate is facing forward (wrong position)
        elseif gravityZ > -reelCastPosition then
            if not castTimer.startTimer then
                -- start buffer timer to see if playdate remains in position
                castTimer.startTimer = true
                castTimer.targetTime = pd.getElapsedTime() + castTimer.totalTime
            end

            -- prevent action if playdate stays in wrong position too long
            if castTimer.timeout and canCast then
                canCast = false
                self.anim = jumpAnim.firstPos
                print("NO NO NO DONT DO THAT")
            end
        end

        -- update gravZ for next frame
        prevZ = gravityZ

        -- if current GravZ and previous GravZ are distant enough, reel has been cast into water
        if canCast and castStrength > reelCastThreshold then
            print("REEL BABY")
            --jumpAnim.whoosh.paused = false
            jumpAnim.whoosh.frame = 1
            self.anim = jumpAnim.whoosh
            reeling = true
        end
    elseif state == states.swinging then
        if reeling then
            local ticksPerRevolution = 1
            local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

            if crankTicks == 1 and self.swingTargetTracker < 3 then
                self.swingTargetTracker += 1
            end

            if self.swingTargetTracker > 2 then
                if not isSwinging then
                    isSwinging = true
                    local easingFunction = playdate.easingFunctions.inSine
                    local lineSegment = pd.geometry.lineSegment.new(self.x, self.y, 215, 140)
                    swingAnim = gfx.animator.new(700, lineSegment, easingFunction)
                    jumpAnim.jump.frame = 1
                    self.anim = jumpAnim.jump
                else
                    if not swingAnim:ended() then
                        if self.x > 70 then
                            self:setScale(1.1, 1.1)
                        end
                        self:moveTo(swingAnim:currentValue())
                    else
                        state = states.idle
                        swingAnim = nil
                        isSwinging = false
                        self.triggerInfo = {}
                        self.playerControl = true
                        canCast = false
                        reeling = false
                        self:setScale(1, 1)
                        self.swingTargetTracker = 0
                    end
                end
            end
        elseif self.swingTargetTracker ~= 0 then
            self.swingTargetTracker = 0
        end
    end
end

function P1:sprayManager()
    if isSpraying then
        local crank = pd.getCrankPosition()
        local change, acceleratedChange = pd.getCrankChange()
        if (acceleratedChange > 15 or acceleratedChange < -15) and (crank > 270 or crank < 90) then
            if not sprayTimer.timeout then
                if not spray:isVisible() then
                    print(" YO YO YO")
                    spray:setUpdatesEnabled(true)
                    spray:setCollisionsEnabled(true)
                    spray:setVisible(true)
                end
                if not sprayTimer.startTimer then
                    sprayTimer.startTimer = true
                end
                sprayTimer.startTimer = true
                sprayTimer.targetTime = pd.getElapsedTime() + sprayTimer.totalTime
            else
                sprayTimer.startTimer = true
                sprayTimer.targetTime = pd.getElapsedTime() + sprayTimer.totalTime
                sprayTimer.timeout = false
            end
        else
            if sprayTimer.timeout then
                if spray:isVisible() then
                    sprayTimer.startTimer = false
                    spray:setVisible(false)
                    spray:setCollisionsEnabled(false)
                    spray:setUpdatesEnabled(false)
                end
            end
        end
    end
end

function P1:logFishing()
    if self.onTrigger and self.triggerInfo[5] and not self.onLog then
        self.onLog = true; self.playerControl = false; self:setImage(spriteSheet.log); self:moveTo(
            self.triggerInfo[1] + 10,
            self.triggerInfo[2] + 10)
        self:setCollideRect(0, 6, 32, 20)
    end

    if not self.onLog then return end

    if pd.buttonJustPressed("A") and state ~= states.logPulling then
        --self.anim = jumpAnim.firstPos
        --self.playerControl = false
        state = states.logPulling
    elseif state == states.logPulling and pd.buttonJustReleased("A") and not reeling then
        state = states.idle
    end

    if state == states.logPulling then
        if not reeling and pd.buttonIsPressed("A") then
            local gravityX, gravityY, gravityZ = pd.readAccelerometer()
            local castStrength = math.abs(gravityZ - prevZ)

            -- check if playdate is pulled back (correct position)
            if gravityZ < reelCastPosition then
                -- allow casting
                if not canCast then
                    canCast = true
                    print("SEND IT, DAWG")
                end

                -- reset timer for buffer check
                if castTimer.startTimer then
                    castTimer.startTimer = false
                    castTimer.timeout = false
                end
                -- check if playdate is facing forward (wrong position)
            elseif gravityZ > -reelCastPosition then
                if not castTimer.startTimer then
                    -- start buffer timer to see if playdate remains in position
                    castTimer.startTimer = true
                    castTimer.targetTime = pd.getElapsedTime() + castTimer.totalTime
                end

                -- prevent action if playdate stays in wrong position too long
                if castTimer.timeout and canCast then
                    canCast = false
                    print("NO NO NO DONT DO THAT")
                end
            end

            -- update gravZ for next frame
            prevZ = gravityZ

            -- if current GravZ and previous GravZ are distant enough, reel has been cast into water
            if canCast and castStrength > reelCastThreshold then
                print("REEL BABY")
                reeling = true
                canCast = false
            end
        elseif reeling then
            local change, acceleratedChange = pd.getCrankChange()
            local goalX, goalY = self.x, self.y
            -- Yoko Ogawa short story collection (author of The Housekeeper and the Professor)
            -- Kazulo Ishiguro (British)

            if change > 30 and reeling then
                if self:getRotation() ~= logDirections[logIndex + 2] then
                    self:setRotation(pd.math.lerp(self:getRotation(), logDirections[logIndex + 2], 0.15))
                end
                goalX += logDirections[logIndex]
                goalY += logDirections[logIndex + 1]
            end

            local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

            for i = 1, #collisions do
                local col = collisions[i]
                local colSP = col.other
                if not colSP.isTrigger then
                    if not colSP.used then
                        reeling = false
                        --colSP.used = true
                        colSP:setCollisionsEnabled(false)
                        logIndex += 3
                    end
                end
            end
        end
    end
end

function P1:bugSpray()
    if state == states.climbing then return end
    if self.ability2 then self.ability2 = false end
    self.ability1 = true
    if spray == nil then
        spray = Spray(self.x, self.y + 20, 20, 20)
        spray:setZIndex(4)
    else
        spray:remove()
        spray = nil
    end

    if not isSpraying then
        isSpraying = true
    else
        state = states.idle
        isSpraying = false
    end
end

function P1:pole()
    if isSpraying then self:bugSpray() end
    if self.ability1 then self.ability1 = false end
    self.ability2 = true
end

function P1:abilityOne()
    self:pole()
end

function P1:abilityTwo()
    self:bugSpray()
end

function P1:changeState(newState, xPos, minRange, maxRange)
    state = newState
    if state == 6 then
        stumpX = xPos
        minClimbRange = minRange
        maxClimbRange = maxRange
    end
end

function P1:animationManager()
    if state == states.swinging then
        --nada
    elseif state == states.walking.left then
        if self.anim ~= walkAnim.left then self.anim = walkAnim.left end
    elseif state == states.walking.right then
        if self.anim ~= walkAnim.right then self.anim = walkAnim.right end
    elseif state == states.walking.front then
        if self.anim ~= walkAnim.front then self.anim = walkAnim.front end
    elseif state == states.walking.back or state == states.climbing then
        if self.anim ~= walkAnim.back then self.anim = walkAnim.back end
    elseif state == states.idle then
        if self.anim ~= idleAnim then self.anim = idleAnim end
    end
end

function P1:collisionResponse(other)
    --P1.super.collisionResponse(self, other)
    if other:isa(Collider) then
        if other.isTrigger or (not self.playerControl and not self.onLog) or (other:isa(Water) and self.onLog) then
            return 'overlap'
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
        if other.swarm then
            self.ded = true
            return 'overlap'
        end
    end
end
