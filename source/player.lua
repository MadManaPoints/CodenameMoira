local pd <const> = playdate
local gfx <const> = pd.graphics

Player = {}

local currentDir = nil
local allDir = { "up", "down", "left", "right" }
local heldDir = {}
local speed = 3
local flying = false
local canDismount = true
local sword
local swordEquipped = false
local canUsePole = false
local stumpX, minClimbRange, maxClimbRange = 0, 0, 0
local spray = nil
local isSpraying = false
local isPlayerOne = false
local isSwinging = false
local sprayTimer = Timer(.75)

local spriteSheet =
{
    femaleIdle = gfx.imagetable.new("images/femaleIdle/femaleIdle"),
    femaleWalk = gfx.imagetable.new("images/femaleWalk/femaleWalk"),
    femaleFlying = gfx.imagetable.new("images/femaleFlying/femaleFlying"),
    maleIdle = gfx.imagetable.new("images/maleIdle/maleIdle"),
    maleWalk = gfx.imagetable.new("images/maleWalk/maleWalk"),
    malePole = gfx.image.new("images/malePole/fishingPole"),
    log = gfx.image.new("images/log"),
    jump = gfx.imagetable.new("images/malePole/jump/fishpoleJump"),
    spray = gfx.imagetable.new("images/spray/spray"),
    sword = gfx.imagetable.new("images/swingAttack/swingAttack")
}

local idleAnim = gfx.animation.loop.new(100, spriteSheet.femaleIdle, true)
local idleAnim2 = gfx.animation.loop.new(150, spriteSheet.maleIdle, true)

local walkAnim =
{
    left = gfx.animation.loop.new(90, spriteSheet.femaleWalk, true),
    right = gfx.animation.loop.new(90, spriteSheet.femaleWalk, true),
    front = gfx.animation.loop.new(70, spriteSheet.femaleWalk, true),
    back = gfx.animation.loop.new(70, spriteSheet.femaleWalk, true),

    left2 = gfx.animation.loop.new(90, spriteSheet.maleWalk, true),
    right2 = gfx.animation.loop.new(90, spriteSheet.maleWalk, true),
    front2 = gfx.animation.loop.new(70, spriteSheet.maleWalk, true),
    back2 = gfx.animation.loop.new(70, spriteSheet.maleWalk, true)
}

walkAnim.left.startFrame = 1
walkAnim.left.endFrame = 4

walkAnim.right.startFrame = 5
walkAnim.right.endFrame = 8

walkAnim.front.startFrame = 9
walkAnim.front.endFrame = 12

walkAnim.back.startFrame = 13
walkAnim.back.endFrame = 16

walkAnim.left2.startFrame = 1
walkAnim.left2.endFrame = 4

walkAnim.right2.startFrame = 5
walkAnim.right2.endFrame = 8

walkAnim.front2.startFrame = 9
walkAnim.front2.endFrame = 12

walkAnim.back2.startFrame = 13
walkAnim.back2.endFrame = 16


local flyAnim =
{
    idle = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    right = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    front = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true),
    back = gfx.animation.loop.new(150, spriteSheet.femaleFlying, true)
}

flyAnim.right.startFrame = 1
flyAnim.right.endFrame = 2

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
    spinFastReverse = gfx.animation.loop.new(75, spriteSheet.sword, true)
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
    walking = { left = 2, right = 3, front = 4, back = 5, left2 = 6, right2 = 7, front2 = 8, back2 = 9 },
    flying = { idle = 10, left = 11, right = 12, front = 13, back = 14 },
    sword = 15,
    climbing = 16,
    spraying = 17,
    swinging = 18,
    pulling = 19,
    logPulling = 20
}

local state = states.idle

class('Player').extends(gfx.sprite)

function Player:init(x, y, alone, first, tag)
    self:setCenter(0.5, 0.5)
    self:moveTo(x, y)
    self.playerControl = true
    isPlayerOne = first
    if isPlayerOne then
        self.anim = idleAnim2
    else
        self.anim = idleAnim
    end
    self.ability1, self.ability2 = false, false
    --local playerSprite = gfx.image.new(img)
    --self:setImage(playerSprite)
    self:setCollideRect(5, 3, 13, 18)
    self.insideTrigger = false

    if not alone then
        if first then
            self.following = false
            self:setCollidesWithGroups(1)
            self.prevX = x + 32
            self.prevY = y
        else
            self.following = true
            self.prevX = x
            self.prevY = y
        end
    else
        self:setCollidesWithGroups({ 1, 2, 3, 6 })
        self.ded = false
        self.following = false
        self.swingTargetTracker = 0
        self.flyDir = { false, false, false, false }
        self.flyingTimer = Timer(0.25)
        self.castTimer = Timer(0.5)
        self.reeling = false
        self.canCast = false
        self.reelCastPosition = -0.7
        self.reelCastThreshold = 1.5
        self.prevZ = 0
        self.castPosition = -0.7
        self.tornado = false
        self.onLog = false
        self.logIndex = 1
        self.logDirections = { 3, 0, 0, 0, 3, 90, -3, 0, 0, 0, -3, 90 }
        self.alone = true

        -- update menu based on current character
        if isPlayerOne then
            pd.getSystemMenu():removeAllMenuItems()
            pd.getSystemMenu():addMenuItem("Bug Spray", function() self:bugSpray() end)
            pd.getSystemMenu():addMenuItem("Rod (Climb)", function() self:pole() end)
        else
            pd.getSystemMenu():removeAllMenuItems()
            pd.getSystemMenu():addMenuItem("Paddle (Fight)", function() self:sword() end)
            pd.getSystemMenu():addMenuItem("Paddle (Flight)", function() self:fly() end)
        end
    end

    self.onTrigger = false
    self.triggerInfo = nil
    self:setTag(tag)
    self:setGroups(2)
    self:setZIndex(5)
    self:add()
end

function Player:update()
    if self.ded then
        self:sword()
        self:moveTo(CurrentCheckpointX, CurrentCheckpointY)
        if self.x == CurrentCheckpointX and self.y == CurrentCheckpointY then self.ded = false end
        return
    end
    if not self.onLog then
        self:setImage(self.anim:image())
        self:animationManager()
        self:itemSelect()
    end

    if not self.following then
        if self.alone then
            if isPlayerOne then
                self:climbManager()
                self:sprayManager()
                self:swingManager()
                self:logFishing()
            else
                self:flyingManager()
            end
        end

        self:switchRooms(self.x, self.y)

        if not self.playerControl then
            return
        end

        local goalX, goalY = self.x, self.y

        -- detect most recent button pressed
        for i, dir in ipairs(allDir) do
            if pd.buttonJustPressed(dir) then
                if not table.indexOfElement(heldDir, dir) then
                    table.insert(heldDir, dir)
                end
            end

            if pd.buttonJustReleased(dir) then
                if table.indexOfElement(heldDir, dir) then
                    table.remove(heldDir, table.indexOfElement(heldDir, dir))
                end
            end
        end

        -- set current direction to nil if no directional buttons are pressed
        if #heldDir == 0 and self.playerControl and not flying then
            if currentDir ~= nil then currentDir = nil end
            if isPlayerOne then
                --if state ~= states.idl2 then state = states.idle2 end
            else
                if not flying then
                    --if state ~= states.idle then state = states.idle end
                else
                    -- need to change to idle when ready
                    --if state ~= states.flying.right then state = states.flying.right end
                end
            end

            -- set most recent button pressed as current direction
        elseif currentDir ~= heldDir[#heldDir] then
            currentDir = heldDir[#heldDir]
        end

        if (not flying and currentDir == "up") or self.flyDir[1] then
            if isPlayerOne then
                if state ~= states.walking.back2 then state = states.walking.back2 end
                if isSpraying then spray:changeDirection(self.x, self.y - 20) end
            else
                if not flying and state ~= states.sword then
                    if state ~= states.walking.back then state = states.walking.back end
                elseif flying then
                    if state ~= states.flying.back then state = states.flying.back end
                end
            end
            goalY -= speed
        elseif (not flying and currentDir == "down") or self.flyDir[2] then
            if isPlayerOne then
                if state ~= states.walking.front2 then state = states.walking.front2 end
                if isSpraying then spray:changeDirection(self.x, self.y + 20) end
            else
                if not flying and state ~= states.sword then
                    if state ~= states.walking.front then state = states.walking.front end
                elseif flying then
                    if state ~= states.flying.front then state = states.flying.front end
                end
            end
            goalY += speed
        end

        if (not flying and currentDir == "left") or self.flyDir[3] then
            if isPlayerOne then
                if state ~= states.walking.left2 then state = states.walking.left2 end
                if isSpraying then spray:changeDirection(self.x - 18, self.y) end
            else
                if not flying and state ~= states.sword then
                    if state ~= states.walking.left then state = states.walking.left end
                elseif flying then
                    --pending
                end
            end
            goalX -= speed
        elseif (not flying and currentDir == "right") or self.flyDir[4] then
            if isPlayerOne then
                if state ~= states.walking.right2 then state = states.walking.right2 end
                if isSpraying then spray:changeDirection(self.x + 18, self.y) end
            else
                if not flying and state ~= states.sword then
                    if state ~= states.walking.right then state = states.walking.right end
                elseif flying then
                    if state ~= states.flying.right then state = states.flying.right end
                end
            end
            goalX += speed
        end

        if self.alone == nil then
            -- lerp following player behind current player
            if currentDir == "up" then
                self.prevY = pd.math.lerp(self.prevY, self.y + 16, 0.25)
                self.prevX = pd.math.lerp(self.prevX, self.x, 0.25)
            elseif currentDir == "down" then
                self.prevY = pd.math.lerp(self.prevY, self.y - 16, 0.25)
                self.prevX = pd.math.lerp(self.prevX, self.x, 0.25)
            end

            if currentDir == "left" then
                self.prevX = pd.math.lerp(self.prevX, self.x + 16, 0.25)
                self.prevY = pd.math.lerp(self.prevY, self.y, 0.25)
            elseif currentDir == "right" then
                self.prevX = pd.math.lerp(self.prevX, self.x - 16, 0.25)
                self.prevY = pd.math.lerp(self.prevY, self.y, 0.25)
            end
        end

        ---- MOVE CURRENT PLAYER ----
        local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

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

        --self:switchRooms(self.x, self.y)
    else
        local goalX, goalY

        -- set course for following player
        if (self:getTag() == 2) then
            goalX, goalY = Manny.prevX, Manny.prevY
        else
            goalX, goalY = Tati.prevX, Tati.prevY
        end
        ---- MOVE FOLLOWING PLAYER ----
        local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
    end
end

function Player:flyingManager()
    if flying then
        local gravityX, gravityY, gravityZ = pd.readAccelerometer()

        if gravityX > -0.2 and gravityX < 0.2 and gravityY > 0.18 and gravityY < 0.7 then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
        end

        --move player up or down based on whether playdate is tilted forward or backward, respectively
        if gravityY <= 0.18 and not self.flyDir[1] then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
            self.flyDir[1] = true
        elseif gravityY >= 0.5 and not self.flyDir[2] then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
            self.flyDir[2] = true
        end

        --move player left or right based on whether playdate is tilted in respective direction
        if gravityX <= -0.2 and not self.flyDir[3] then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
            self.flyDir[3] = true
        elseif gravityX >= 0.2 and not self.flyDir[4] then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
            self.flyDir[4] = true
        end
    else
        -- ensure movement reverts to default when no longer flying
        if not isPlayerOne then
            for i = 1, #self.flyDir do
                if self.flyDir[i] then self.flyDir[i] = false end
            end
        end
    end
end

function Player:fly()
    if not canDismount then return end

    if swordEquipped then
        --sword:setVisible(false)
        --sword:setCollisionsEnabled(false)
        --sword:setUpdatesEnabled(false)
        swordEquipped = false
    end

    if not flying then
        state = states.flying.right
        speed = 6
    else
        state = states.idle
        speed = 3
    end

    flying = not flying
    if self.ability2 then
        self.ability2 = false
    end
    if not self.ability1 then self.ability1 = true end
end

function Player:sword()
    if not canDismount and not self.ded then return end

    --add sword if there's no sword in the scene
    if sword == nil then
        sword = Sword(Tati.x, Tati.y)
    end

    if flying then
        speed = 3
        flying = false
    end

    -- turn sword on or off
    if state ~= states.sword then
        self:setCollideRect(17, 12, 13, 18)
        --sword:setUpdatesEnabled(true)
        --sword:setCollisionsEnabled(true)
        --sword:setVisible(true)
        state = states.sword
    else
        --sword:setVisible(false)
        --sword:setCollisionsEnabled(false)
        --sword:setUpdatesEnabled(false)
        state = states.idle
    end

    swordEquipped = not swordEquipped
    if self.ability1 then self.ability1 = false end
    if not self.ability2 then self.ability2 = true end
end

function Player:climbManager()
    if self.ability2 then
        if state ~= states.climbing and pd.buttonJustPressed("A") then
            if not self.onTrigger then return end
            if isSpraying then self:bugSpray() end
            local info = self.triggerInfo
            self.playerControl = false
            self:changeState(16, info[1] + 10, self.y, info[3])
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
                    state = states.idle2
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
                    state = states.idle2
                end
            end
        end
    end
end

function Player:swingManager()
    if self.ability2 and pd.buttonJustPressed("A") and self.onTrigger and self.triggerInfo[4] and state ~= states.swinging then
        self.anim = jumpAnim.firstPos
        self.playerControl = false
        state = states.swinging
    elseif state == states.swinging and pd.buttonJustReleased("A") and not self.reeling then
        state = states.idle2
        self.playerControl = true
        self.canCast = false
    end

    if state == states.swinging and not self.reeling then
        local gravityX, gravityY, gravityZ = pd.readAccelerometer()
        local castStrength = math.abs(gravityZ - self.prevZ)

        -- check if playdate is pulled back (correct position)
        if gravityZ < self.reelCastPosition then
            -- allow casting
            if not self.canCast then
                self.canCast = true
                self.anim = jumpAnim.secondPos
                print("SEND IT, DAWG")
            end


            -- reset timer for buffer check
            if self.castTimer.startTimer then
                self.castTimer.startTimer = false
                self.castTimer.timeout = false
            end
            -- check if playdate is facing forward (wrong position)
        elseif gravityZ > -self.reelCastPosition then
            if not self.castTimer.startTimer then
                -- start buffer timer to see if playdate remains in position
                self.castTimer.startTimer = true
                self.castTimer.targetTime = pd.getElapsedTime() + self.castTimer.totalTime
            end

            -- prevent action if playdate stays in wrong position too long
            if self.castTimer.timeout and self.canCast then
                self.canCast = false
                self.anim = jumpAnim.firstPos
                print("NO NO NO DONT DO THAT")
            end
        end

        -- update gravZ for next frame
        self.prevZ = gravityZ

        -- if current GravZ and previous GravZ are distant enough, reel has been cast into water
        if self.canCast and castStrength > self.reelCastThreshold then
            print("REEL BABY")
            --jumpAnim.whoosh.paused = false
            jumpAnim.whoosh.frame = 1
            self.anim = jumpAnim.whoosh
            self.reeling = true
        end
    elseif state == states.swinging then
        if self.reeling then
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
                        state = states.idle2
                        swingAnim = nil
                        isSwinging = false
                        self.triggerInfo = {}
                        self.playerControl = true
                        self.canCast = false
                        self.reeling = false
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

function Player:sprayManager()
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
                    self.startTimer = false
                    spray:setVisible(false)
                    spray:setCollisionsEnabled(false)
                    spray:setUpdatesEnabled(false)
                end
            end
        end
    end
end

function Player:logFishing()
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
    elseif state == states.logPulling and pd.buttonJustReleased("A") and not self.reeling then
        state = states.idle2
    end

    if state == states.logPulling then
        if not self.reeling and pd.buttonIsPressed("A") then
            local gravityX, gravityY, gravityZ = pd.readAccelerometer()
            local castStrength = math.abs(gravityZ - self.prevZ)

            -- check if playdate is pulled back (correct position)
            if gravityZ < self.reelCastPosition then
                -- allow casting
                if not self.canCast then
                    self.canCast = true
                    print("SEND IT, DAWG")
                end

                -- reset timer for buffer check
                if self.castTimer.startTimer then
                    self.castTimer.startTimer = false
                    self.castTimer.timeout = false
                end
                -- check if playdate is facing forward (wrong position)
            elseif gravityZ > -self.reelCastPosition then
                if not self.castTimer.startTimer then
                    -- start buffer timer to see if playdate remains in position
                    self.castTimer.startTimer = true
                    self.castTimer.targetTime = pd.getElapsedTime() + self.castTimer.totalTime
                end

                -- prevent action if playdate stays in wrong position too long
                if self.castTimer.timeout and self.canCast then
                    self.canCast = false
                    print("NO NO NO DONT DO THAT")
                end
            end

            -- update gravZ for next frame
            self.prevZ = gravityZ

            -- if current GravZ and previous GravZ are distant enough, reel has been cast into water
            if self.canCast and castStrength > self.reelCastThreshold then
                print("REEL BABY")
                self.reeling = true
                self.canCast = false
            end
        elseif self.reeling then
            local change, acceleratedChange = pd.getCrankChange()
            local goalX, goalY = self.x, self.y
            -- Yoko Ogawa short story collection (author of The Housekeeper and the Professor)
            -- Kazulo Ishiguro (British)

            if change > 30 and self.reeling then
                if self:getRotation() ~= self.logDirections[self.logIndex + 2] then
                    self:setRotation(pd.math.lerp(self:getRotation(), self.logDirections[self.logIndex + 2], 0.15))
                end
                goalX += self.logDirections[self.logIndex]
                goalY += self.logDirections[self.logIndex + 1]
            end

            local actualX, actualY, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)

            for i = 1, #collisions do
                local col = collisions[i]
                local colSP = col.other
                if not colSP.isTrigger then
                    if not colSP.used then
                        self.reeling = false
                        --colSP.used = true
                        colSP:setCollisionsEnabled(false)
                        self.logIndex += 3
                    end
                end
            end
        end
    end
end

function Player:logCanoe()

end

function Player:bugSpray()
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
        --self.playerControl = false
        --state = states.spraying
        isSpraying = true
    else
        --self.playerControl = true
        state = states.idle2
        isSpraying = false
    end
end

function Player:pole()
    if isSpraying then self:bugSpray() end
    if self.ability1 then self.ability1 = false end
    self.ability2 = true
    --self.ability2 = not self.ability2
end

function Player:animationManager()
    if isPlayerOne then
        if state == states.swinging then
            --nada
        elseif state == states.walking.left2 then
            if self.anim ~= walkAnim.left2 then self.anim = walkAnim.left2 end
        elseif state == states.walking.right2 then
            if self.anim ~= walkAnim.right2 then self.anim = walkAnim.right2 end
        elseif state == states.walking.front2 then
            if self.anim ~= walkAnim.front2 then self.anim = walkAnim.front2 end
        elseif state == states.walking.back2 or state == states.climbing then
            if self.anim ~= walkAnim.back2 then self.anim = walkAnim.back2 end
        elseif state == states.idle2 then
            if self.anim ~= idleAnim2 then self.anim = idleAnim2 end
        end
    else
        if state == states.sword then
            if sword.spin > 0 then
                if sword.spin < 30 then
                    if self.tornado then
                        self.tornado = false
                        swordAnim.spinSlowForward.frame = self.anim.frame
                    end
                    if not sword:isVisible() then
                        --sword:setUpdatesEnabled(true)
                        --sword:setCollisionsEnabled(true)
                        --sword:setVisible(true)
                    end
                    if self.anim ~= swordAnim.spinSlowForward then self.anim = swordAnim.spinSlowForward end
                elseif sword.spin >= 30 then
                    if not self.tornado then
                        self.tornado = true
                        swordAnim.spinFastForward.frame = self.anim.frame
                    end
                    if self.anim ~= swordAnim.spinFastForward then self.anim = swordAnim.spinFastForward end
                end
            elseif sword.spin < 0 then
                if sword.spin > -30 then
                    if self.tornado then
                        self.tornado = false
                        swordAnim.spinSlowReverse.frame = self.anim.frame
                    end
                    if not sword:isVisible() then
                        --sword:setUpdatesEnabled(true)
                        --sword:setCollisionsEnabled(true)
                        --sword:setVisible(true)
                    end
                    if self.anim ~= swordAnim.spinSlowReverse then self.anim = swordAnim.spinSlowReverse end
                elseif sword.spin <= -30 then
                    if not self.tornado then
                        self.tornado = true
                        swordAnim.spinFastReverse.frame = self.anim.frame
                    end
                    if self.anim ~= swordAnim.spinFastReverse then self.anim = swordAnim.spinFastReverse end
                end
            elseif sword.speed == 0 then
                swordAnim.spinSlowForward.frame = 1
                swordAnim.spinFastForward.frame = 1
                if self.anim ~= swordAnim.idle then self.anim = swordAnim.idle end
                if self.tornado then
                    self.tornado = false
                end
                if sword:isVisible() then
                    --sword:setUpdatesEnabled(false)
                    --sword:setCollisionsEnabled(false)
                    --sword:setVisible(false)
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
        elseif state == states.flying.front then
            if self.anim ~= flyAnim.front then self.anim = flyAnim.front end
        elseif state == states.flying.back then
            if self.anim ~= flyAnim.back then self.anim = flyAnim.back end
        end
    end
end

function Player:itemSelect()
    if isPlayerOne then
        if not self.ability2 and pd.buttonJustPressed("A") then
            self:pole()
        end
        if not self.ability1 and pd.buttonJustPressed("B") then
            self:bugSpray()
        end
    else
        if not self.ability2 and pd.buttonJustPressed("A") then
            self:sword()
        end
        if not self.ability1 and pd.buttonJustPressed("B") and not self.tornado then
            self:fly()
        end
    end
end

function Player:switchRooms(x, y)
    -- loop through all rooms and choose next room based on where player exits
    if x < 0 then
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                if sword ~= nil then sword = nil end
                GAME_MANAGER:switchScene(Room(r.left, "images/rooms/night1/room" .. tostring(r.left)), 388, y,
                    isPlayerOne)
                break
            end
        end
    end
    if x > 400 then
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                GAME_MANAGER:switchScene(Room(r.right, "images/rooms/night1/room" .. tostring(r.right)), 12, y,
                    isPlayerOne)
                break
            end
        end
    end
    if y < 0 then
        local newX = x
        --print(newX)
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                GAME_MANAGER:switchScene(Room(r.up, "images/rooms/night1/room" .. tostring(r.up)), newX, 228, isPlayerOne)
            end
        end
    end
    if y > 240 then
        if state == states.climbing then
            self.playerControl = true
            state = states.idle
        end
        local newX = x
        --print(newX)
        for k, r in pairs(RoomTracker) do
            if r.id == RoomID then
                if r.id == 4 then
                    isPlayerOne = true
                    GAME_MANAGER:switchScene(Room(1, "images/rooms/night1/room1"), 380, 100,
                        isPlayerOne)
                    break
                else
                    GAME_MANAGER:switchScene(Room(r.down, "images/rooms/night1/room" .. tostring(r.down)), newX, 12,
                        isPlayerOne)
                    break
                end
            end
        end
    end
end

function Player:changeState(newState, xPos, minRange, maxRange)
    state = newState
    if state == 16 then
        stumpX = xPos
        minClimbRange = minRange
        maxClimbRange = maxRange
    end
end

function Player:collisionResponse(other)
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
        if other.swarm then
            self.ded = true
            return 'overlap'
        end
    end
end
