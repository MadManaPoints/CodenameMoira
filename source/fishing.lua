local pd <const> = playdate
local gfx <const> = pd.graphics

Fishing = {}

class('Fishing').extends(gfx.sprite)

local timer = Timer(5)
local castTimer = Timer(0.5)
local fishingTimer = Timer(3)
local canCast = false
local whoosh = false
local reeling = false
local reelHealth = 100.0
local prevGravityZ = 0
local reelCastPosition = -0.7
local reelCastThreshold = 1.7

function Fishing:init()
    self.fishingStarted = false
    self:add()
end

function Fishing:update()
    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank)
    local change, acceleratedChange = pd.getCrankChange()

    local gravityX, gravityY, gravityZ = pd.readAccelerometer()
    local castStrength = math.abs(gravityZ - prevGravityZ)

    if timer.timeout and not self.canFish then
        self.canFish = true
    end

    -- check if playdate is pulled back (correct position)
    if gravityZ < reelCastPosition and not reeling then
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
        if castTimer.timeout and canCast and not whoosh then
            canCast = false
            print("NO NO NO DONT DO THAT")
        end
    end

    -- update gravZ for next frame
    prevGravityZ = gravityZ

    -- if current GravZ and previous GravZ are distant enough, reel has been cast into water
    if canCast and castStrength > reelCastThreshold and not whoosh then
        print("WHOOSH")
        whoosh = true
        -- start timer to determine how long to wait for bite (*will randomize eventually*)
        fishingTimer.targetTime = pd.getElapsedTime() + fishingTimer.totalTime
        fishingTimer.startTimer = true
    end

    ---NOTE: currently there's no detection for reeling before fishing timer goes off---

    -- alter player that fish has taken the bait
    if fishingTimer.timeout and not reeling then
        print("REEL 'EM IN")
        reeling = true
    end

    -- reduce Reel Health using crank speed
    if reeling then
        if reelHealth <= 0 then
            if change < 0 then
                reelHealth += acceleratedChange * 0.005
            end
        else
            -- reveal fish once Reel Health reaches 0
            print("GOT 'EM")
        end
    end
end
