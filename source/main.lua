--doc will show different coreLibs you can use
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
import "breakable"
import "waterfall"
import "worldobject"
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
-- 380, 100
local startX, startY = 380, 100
CurrentCheckpointX = startX
CurrentCheckpointY = startY
PlayerOneActive = true

--- FIRST PROTOTYPE ---
MinigameTrigger = false -- temp
local minigameStart = false
VictoryDictory = false
DemoEnd = false

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
    --Manny = P1(150, 30, true, true)
    Manny = P1(100, 100, true, true)
    --Tati = P2(startX, startY, true, false)

    --local roomTest = Room("images/roomTest")
    local firstRoom = 5
    RoomID = firstRoom
    local room1 = Room(firstRoom, "images/rooms/night1/room" .. tostring(firstRoom))

    -- TEST MINIGAME --
    --GAME_MANAGER:startMinigame(Room(firstRoom, "images/rooms/night1/room" .. tostring(firstRoom)), 1)

    --local co = coroutine.create(function() print("hi") end)
    --pd.ui.crankIndicator:draw()
    P = Pathfinding()

    local menu = playdate.getSystemMenu()
    menu:addMenuItem("Switch", function() ChangeActivePlayer() end)
end

--local fishing = Fishing()

--- **DEBUGGING** ---
gfx.setColor(gfx.kColorWhite)

initialize()


function pd.update()
    gfx.clear()
    Delta = pd.getElapsedTime()
    gfx.sprite.update()
    --if fishing.canFish then
    --    gfx.drawText("START", 50, 50)
    --end
    --if TwoPlayers and (pd.buttonJustPressed("B")) then
    --    ChangePlaces()
    --end

    --- **DEBUGGING** ---
    --gfx.fillRect(0, 0, 80, 40)
    --gfx.drawText(tostring(test), 10, 10)

    if MinigameTrigger and not minigameStart then
        gfx.fillRect(0, 0, 400, 240)
        gfx.drawText("Oh no! Manny is caught in the current.", 50, 50)
        gfx.drawText("Guide Tati through the level to save him!", 30, 100)
        gfx.drawText("Use the menu button to switch characters.", 30, 150)
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
            gfx.drawText("Your partner got swept away!", 85, 100)
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
end

function SwitchPlayer()
    pd.getSystemMenu():removeAllMenuItems()

    local menu = playdate.getSystemMenu()
    menu:addMenuItem("Switch", function() ChangeActivePlayer() end)
end

function ChangeActivePlayer()
    PlayerOneActive = not PlayerOneActive
    if not PlayerOneActive and Manny.onLog then Manny:logMinigameSwitch() end
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
