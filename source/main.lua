import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/math"
import "CoreLibs/crank"
import "CoreLibs/ui"

--my scripts
import "manager"
import "collider"
import "slingshot"
import "timer"
import "player"
import "p1"
import "p2"
import "rope"
import "breakable"
import "waterfall"
import "worldobject"
import "characterSwitchUI"
import "abilitySwitchUI"
import "room"
import "pathfinding"
import "enemy"
import "kayak"
import "chopping"
import "fishing"
import "sword"

local pd <const> = playdate
local gfx <const> = pd.graphics

pd.startAccelerometer()

GAME_MANAGER = Manager()
Delta = 0

local startX, startY = 368, 100
CurrentCheckpointX = startX
CurrentCheckpointY = startY
PlayerOneActive = false
Meanwhile = false
Switching = false
CharacterUIActive = false

--- FIRST PROTOTYPE ---
MinigameTrigger = false -- temp
local minigameStart = false
VictoryDictory = false
DemoEnd = false

local climbX, climbY
local swordTutorial = true

local function initialize()
    local textImg = gfx.image.new(300, 20)
    --achieves same effect of push and pop
    gfx.lockFocus(textImg)
    --gfx.drawText("YERRR, THIS IS A TEST", 0, 0)
    gfx.unlockFocus()
    local textSprite = gfx.sprite.new(textImg)
    textSprite:setZIndex(30)
    textSprite:moveTo(260, 15)
    --textSprite:add()

    --local kayak = Kayak(200, 200)
    --local chopping = Chopping()
    TwoPlayers = false
    --Manny = P1(250, 30, true, true)
    --Manny = P1(startX, startY, true, true)
    --local abilityUI = AbilitySwitchUI()
    Tati = P2(startX, startY, true, false)

    --local roomTest = Room("images/roomTest")
    local firstRoom = 1
    RoomID = firstRoom
    local room1 = Room(firstRoom, "images/rooms/night1/room" .. tostring(firstRoom))

    local ui = UI(312, 0, 88, 44)

    --local co = coroutine.create(function() print("hi") end)
    --pd.ui.crankIndicator:draw()
    P = Pathfinding()

    --local menu = playdate.getSystemMenu()
    --menu:addMenuItem("Switch", function() ChangeActivePlayer() end)
end

local test = 0
--local fishing = Fishing()

--- **DEBUGGING** ---
gfx.setColor(gfx.kColorWhite)

initialize()


function pd.update()
    gfx.clear()
    Delta = pd.getElapsedTime()
    pd.resetElapsedTime()

    gfx.sprite.update()
    pd.timer.updateTimers();

    if swordTutorial then
        if Tati.ability1 then
            pd.ui.crankIndicator:draw()
        end
        if Tati.x < 350 then
            swordTutorial = false
        end
    end

    if Manny ~= nil and not Manny.onLog and Manny.isClimbing and Manny.y ~= Manny.maxClimbRange then
        --print("YERRRB")
        pd.ui.crankIndicator.clockwise = false
        pd.ui.crankIndicator:draw()
    end

    if Manny ~= nil and ((Manny.onLog and Manny.reeling) or (not Manny.onLog and Manny.reeling)) and not MinigameTrigger then
        pd.ui.crankIndicator.clockwise = true
        if RoomID == 5 then
            pd.ui.crankIndicator:draw(-150, -60)
        else
            pd.ui.crankIndicator:draw()
        end
    end

    --if fishing.canFish then
    --    gfx.drawText("START", 50, 50)
    --end
    --if TwoPlayers and (pd.buttonJustPressed("B")) then
    --    ChangePlaces()
    --end

    --- **DEBUGGING** ---
    --gfx.fillRect(0, 0, 80, 40)
    --gfx.drawText(tostring(test), 10, 10)

    if Meanwhile then
        gfx.fillRect(0, 0, 400, 240)
        gfx.drawText("Meanwhile...", 150, 110)

        -- Temporary player transition
        if Manny ~= nil and Manny.playerControl then
            Manny.playerControl = false
        end

        if pd.buttonJustPressed('A') then
            Meanwhile = false
            Manny.playerControl = true
        end
    end

    if MinigameTrigger and not minigameStart then
        gfx.fillRect(0, 0, 400, 240)
        gfx.drawText("Oh no! Manny is caught in the current.", 50, 50)
        gfx.drawText("Guide Tati through the level to save him!", 45, 80)
        gfx.drawText("Hold B to bring up character menu.", 60, 140)
        gfx.drawText("Press any d-pad button to switch characters.", 25, 170)
        gfx.drawText("Press A to start.", 250, 220)

        if pd.buttonJustPressed('A') then
            minigameStart = true
            GAME_MANAGER:startMinigame(1)
        end
    end

    if DemoEnd then
        gfx.fillRect(0, 0, 400, 240)
        if VictoryDictory then
            gfx.drawText("Thank you for playing!", 120, 110)
        else
            gfx.drawText("Manny got swept away!", 110, 100)
            gfx.drawText("Press A to try again.", 120, 130)

            -- Allow minigame reset if player loses
            if pd.buttonJustPressed('A') then
                DemoEnd = false
                GAME_MANAGER:startMinigame(1)
            end
        end
    end
    --P:drawGrid()
    --P:updatePath()
    if PlayerOneActive then
        if Manny.isClimbing then
            if Manny.triggerInfo ~= nil and climbX ~= Manny.triggerInfo[1] then
                climbX = Manny.triggerInfo[1] + 10
                climbY = Manny.triggerInfo[2]
            end
            gfx.setColor(gfx.kColorWhite)
            gfx.setLineWidth(3)
            gfx.drawLine(Manny.x, Manny.y - 10, climbX, climbY)
            gfx.setColor(gfx.kColorBlack)
            gfx.setLineWidth(1.5)
            gfx.drawLine(Manny.x + 2, Manny.y - 10, climbX, climbY)
            gfx.setColor(gfx.kColorWhite)
        end

        if Manny.reeling then
            --
        end
    end
end

function SwitchPlayer()
    pd.getSystemMenu():removeAllMenuItems()

    local menu = playdate.getSystemMenu()
    menu:addMenuItem("Switch", function() ChangeActivePlayer() end)
end

function ChangeActivePlayer()
    PlayerOneActive = not PlayerOneActive
    if not PlayerOneActive and Manny.onLog then
        Manny:logMinigameSwitch()
    end
    Tati:updateUI()
end

function ChangePlaces()
    -- switch characters and menu items
    if Tati.following then
        Tati.prevX, Tati.prevY = Manny.prevX, Manny.prevY
        Tati:moveTo(Manny.x, Manny.y)

        pd.getSystemMenu():removeAllMenuItems()
        -- new menu items go here
    else
        Manny.prevX, Manny.prevY = Tati.prevX, Tati.prevY
        Manny:moveTo(Tati.x, Tati.y)

        pd.getSystemMenu():removeAllMenuItems()
        -- new menu items go here
    end

    Manny.following = not Manny.following
    Tati.following = not Tati.following
end
