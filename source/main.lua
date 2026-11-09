import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/animation"
import "CoreLibs/timer"
import "CoreLibs/object"
import "CoreLibs/math"
import "CoreLibs/crank"
import "CoreLibs/ui"

-- MY SCRIPTS --
import "dialogue"
import "verlet"
import "manager"
import "collider"
import "slingshot"
import "timer"
import "cooldown"
import "player"
import "p1"
import "p2"
import "rope"
import "breakable"
import "waterfall"
import "worldobject"
import "buoy"
import "characterSwitchUI"
import "abilitySwitchUI"
import "room"
import "pathfinding"
import "enemy"
import "kayak"
import "chopping"
import "fishing"
import "sword"

--- OTHER SCRIPTS ---
import "pdDialogue" --[[ Developed by: GammaGames, PizzaFuelDev and NickSr ]] --

local pd <const> = playdate
local gfx <const> = pd.graphics

------------------------------------------------------------------
--- DIALOGUE ---
------------------------------------------------------------------
Dialogue = nil
local x, y = 5, 5

function StartDialogue(text, _onClose)
    local width, height = 390, 56

    -- Create the box with the text and dimensions
    local dialogue = pdDialogueBox(text, width, height)

    -- Add input handlers from the helper function
    pd.inputHandlers.push(dialogue:getInputHandlers())
    -- Override the function to pop the handlers When the box closes
    function dialogue:onClose()
        _onClose()
        playdate.inputHandlers.pop()
    end

    dialogue:enable()

    return dialogue
end

local onDialogueEnd = function()
    print "FIN"
end

Dialogue = StartDialogue(AllDialogue.Intro, onDialogueEnd)
------------------------------------------------------------------
------------------------------------------------------------------

pd.startAccelerometer()

GAME_MANAGER = Manager()
DIALOGUE_MANAGER = DialogueSystem()
Delta = 0

local startDialogue = false

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

-- Line targets when reeling
local climbX, climbY
local reelX, reelY

local swordTutorial = false

CloseDialogue = true
local verletTest = false

local function initialize()
    --[[local textImg = gfx.image.new(400, 20)
    gfx.lockFocus(textImg)
    gfx.drawText("Verlet Test", 150, 0)
    gfx.unlockFocus()
    local textSprite = gfx.sprite.new(textImg)
    textSprite:setZIndex(30)
    textSprite:moveTo(200, 20)
    textSprite:add()--]]

    --local kayak = Kayak(200, 200)
    --local chopping = Chopping()

    TwoPlayers = true
    --Manny = P1(150, 60, true, true)

    --Manny = P1(startX, startY, false, true)//
    --Tati = P2(startX, startY, false, false)

    --local abilityUI = AbilitySwitchUI()

    --local characterUI = CharacterSwitchUI()//

    --local dialogueSystem = DialogueSystem()

    --local roomTest = Room("images/roomTest")
    --local firstRoom = 1
    --RoomID = firstRoom
    --local room1 = Room(firstRoom, "images/rooms/night1/room" .. tostring(firstRoom))
    --[[GAME_MANAGER:switchScene
    (
        Room(5, "images/rooms/night1/room5", true), 140, 60,
        true
    ) --]]
    --local testCol = DialogueTrigger(50, 50, 50, 50, AllDialogue.Intro)
    --local ui = UI(312, 0, 88, 44)

    --local co = coroutine.create(function() print("hi") end)
    --pd.ui.crankIndicator:draw()
    P = Pathfinding()

    --local menu = playdate.getSystemMenu()
    --menu:addMenuItem("Switch", function() ChangeActivePlayer() end)

    --local verlet = Verlet(200, 80, 350, 200)
end

local test = 0

local function counter()
    local i = 0

    return function()
        i += 1
        return i
    end
end

local c = counter()
--local fishing = Fishing()

--- **DEBUGGING** ---
--gfx.setColor(gfx.kColorBlack)

--pdDialogue.say("YERRrrrrrrrrrrrrRR")
initialize()


function pd.update()
    gfx.clear()
    Delta = pd.getElapsedTime()
    pd.resetElapsedTime()
    gfx.sprite.update()
    pd.timer.updateTimers()

    ---[[
    if Dialogue.enabled then
        Dialogue:update()
        Dialogue:draw(x, y)
    end --]]

    if verletTest then return end

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
    if TwoPlayers and (pd.buttonJustPressed("B")) then
        --ChangePlaces()
    end

    --- **DEBUGGING** ---
    --gfx.fillRect(0, 0, 80, 40)
    --gfx.drawText(tostring(test), 10, 10)
    if Meanwhile then
        gfx.setColor(gfx.kColorWhite)
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
        gfx.drawText("Hold B to bring up character menu, then", 25, 140)
        gfx.drawText("press any d-pad button to switch characters.", 25, 170)
        gfx.drawText("Press A to start.", 250, 215)

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
            gfx.drawText("Remember: B + d-pad to switch characters.", 10, 215)

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
    if not PlayerOneActive and Manny.onLog then
        Manny:logMinigameSwitch()
    end
    Tati:updateUI()
end

function ChangePlaces()
    -- switch characters and menu items
    if not PlayerOneActive then
        Manny:moveTo(Tati.x, Tati.y)
        Manny.prevX, Manny.prevY = Tati.prevX, Tati.prevY
        Tati:moveTo(Tati.prevX, Tati.prevY)
    else
        Tati:moveTo(Manny.x, Manny.y)
        Tati.prevX, Tati.prevY = Manny.prevX, Manny.prevY
        Manny:moveTo(Manny.prevX, Manny.prevY)
    end

    Manny.following, Tati.following = Tati.following, Manny.following

    --Manny.following = not Manny.following
    --Tati.following = not Tati.following
    PlayerOneActive = not PlayerOneActive
end

function DrawDialogue(text)
    DIALOGUE_MANAGER:revealText(text)
end
