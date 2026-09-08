--doc will show different coreLibs you can use
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/math"
import "CoreLibs/crank"

--my scripts
import "manager"
import "collider"
import "slingshot"
import "timer"
import "player"
import "p1"
import "p2"
import "breakable"
import "room"
import "enemy"
import "kayak"
import "chopping"
import "fishing"
import "sword"

local pd <const> = playdate
local gfx <const> = pd.graphics

pd.startAccelerometer()

GAME_MANAGER = Manager()
CurrentCheckpointX = 0
CurrentCheckpointY = 0

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
    --Manny = P1(330, 30, true, true)
    --Manny = P1(380, 100, true, true)
    Tati = P2(380, 100, true, false)

    --local roomTest = Room("images/roomTest")
    local firstRoom = 1
    RoomID = firstRoom
    local room1 = Room(firstRoom, "images/rooms/night1/room" .. tostring(firstRoom))


    --local co = coroutine.create(function() print("hi") end)
end

--local fishing = Fishing()

initialize()


function pd.update()
    gfx.clear()
    gfx.sprite.update()

    --if fishing.canFish then
    --    gfx.drawText("START", 50, 50)
    --end
    if TwoPlayers and (pd.buttonJustPressed("B")) then
        ChangePlaces()
    end
end

function ChangePlaces()
    -- switch characters and menu items
    if Tati.following then
        Tati.prevX, Tati.prevY = Manny.prevX, Manny.prevY
        Tati:moveTo(Manny.x, Manny.y)

        pd.getSystemMenu():removeAllMenuItems()
        pd.getSystemMenu():addMenuItem("Map", initialize)
        pd.getSystemMenu():addMenuItem("Paddle", initialize)
    else
        Manny.prevX, Manny.prevY = Tati.prevX, Tati.prevY
        Manny:moveTo(Tati.x, Tati.y)

        pd.getSystemMenu():removeAllMenuItems()
        pd.getSystemMenu():addMenuItem("Bug Spray", initialize)
        pd.getSystemMenu():addMenuItem("Fishing Rod", initialize)
    end

    Manny.following = not Manny.following
    Tati.following = not Tati.following
end
