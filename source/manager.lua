local pd <const> = playdate
local gfx <const> = pd.graphics

Manager = {}

Trackers =
{
    day =
    {
        day1 =
        {
            rooms =
            {
                room1 =
                {
                    id = 1,
                    up = 5,
                    down = 2,
                    right = 3,
                    left = 4,
                    brambles = { false, false },
                    carrot = false
                },

                room2 =
                {
                    id = 2,
                    up = 1,
                    down = nil,
                    right = nil,
                    left = nil,
                },

                room3 =
                {
                    id = 3,
                    up = nil,
                    down = nil,
                    right = nil,
                    left = 1,
                },

                room4 =
                {
                    id = 4,
                    up = nil,
                    down = nil,
                    right = 1,
                    left = nil
                }
            },

            canoeing =
            {
                canoe1 =
                {
                    id = 1,
                    up = 2
                },

                canoe2 =
                {
                    id = 2,
                    up = 3,
                    down = 4
                },

                canoe3 =
                {
                    id = 3,
                    down = 4
                }
            }

        }

    },
    night =
    {
        night1 =
        {
            ["rooms"] =
            {
                ["room1"] =
                {
                    id = 1,
                    up = nil,
                    down = 3,
                    left = 2,
                    right = nil,
                    ["brambles"] = { false, false, false, false, false, false }
                },
                ["room2"] =
                {
                    id = 2,
                    up = nil,
                    down = 4,
                    left = nil,
                    right = 1,
                    ["brambles"] = { false, false, false, false, false, false, false, false }
                },
                ["room3"] =
                {
                    id = 3,
                    up = 1,
                    down = 5,
                    left = 4,
                    right = nil,
                    ["enemies"] = { false, false }
                },
                ["room4"] =
                {
                    id = 4,
                    up = 2,
                    down = 6,
                    left = nil,
                    right = 3,
                    ["enemies"] =
                    {
                        ["monster1"] = { false, x = 0, y = 0 },
                        ["monster2"] = { false, x = 0, y = 0 },
                        ["monster3"] = { false, x = 0, y = 0 }
                    }
                },
                ["room5"] = { id = 5, up = 3, down = nil, left = 6, right = nil },
                ["room6"] = {
                    id = 6,
                    up = nil,
                    down = nil,
                    left = nil,
                    right = nil,
                    --["brambles"] = { false, false, false },
                    ["enemies"] = { false, false, false }
                },
            }
        }
    }
}

-- OLD --
RoomTracker = {
    ["room1"] = { id = 1, up = nil, down = 3, left = 2, right = nil },
    ["room2"] = { id = 2, up = nil, down = 4, left = nil, right = 1 },
    ["room3"] = { id = 3, up = 1, down = 5, left = 4, right = nil },
    ["room4"] = { id = 4, up = 2, down = 6, left = nil, right = 3 },
    ["room5"] = { id = 5, up = 3, down = nil, left = 6, right = nil },
    ["room6"] = { id = 6, up = nil, down = nil, left = nil, right = nil },
}



class('Manager').extends()

function Manager:switchScene(scene, x, y, ...)
    self.room = scene
    self:loadNewScene(x, y, ...)
end

function Manager:startMinigame(minigameNum)
    local x1, y1, x2, y2
    if minigameNum == 1 then
        x1 = 370; y1 = 100
        x2 = 50; y2 = 30

        self.room = Room(6, "images/rooms/night1/room6Table/room6-table-1", true)

        if Tati ~= nil then
            Tati:roomCheck()
        end
    end


    self:loadMinigame(x1, y1, x2, y2, minigameNum)
end

function Manager:loadNewScene(x, y, addBothPlayers, isPlayerOne, currentDir, roomCheck)
    gfx.sprite.removeAll() -- clear sprites before drawing new scene
    self.room:add()        -- adds scene set as argument in transition

    if x == nil then return end

    -- Update player checkpoint
    CurrentCheckpointX = x
    CurrentCheckpointY = y

    if addBothPlayers then
        Manny = P1(x, y, false, true, currentDir)
        Tati = P2(x, y, false, false, currentDir)

        if CurrentDay == 3 then
            local ui = UI(312, 0, 88, 44)
        end
    else
        -- Add current player to scene
        if not isPlayerOne then
            Tati = P2(x, y, true, false, currentDir, roomCheck)
        else
            Manny = P1(x, y, true, true, currentDir, roomCheck)
        end

        local ui = UI(312, 0, 88, 44)
    end
end

function Manager:loadMinigame(x1, y1, x2, y2, minigameNum)
    gfx.sprite.removeAll()
    self.room:add()

    -- Update player checkpoint
    CurrentCheckpointX = x2
    CurrentCheckpointY = y2

    -- Add both players to scene
    Tati = P2(x2, y2, true, false, nil, true)
    Manny = P1(x1, y1, true, true)

    if minigameNum == 1 then
        -- Reset all player variables for log minigame
        Manny:logMinigame()
        Tati:logMinigame()
    end

    local ui = UI(312, 0, 88, 44)
end

function Manager:loadActivity(minigameNum)
    gfx.sprite.removeAll()


    if minigameNum == 1 then
        self.room = Room(1, "images/rooms/canoeing/canoeMap1", nil, true)
        local canoe = Canoe(200, 700)
    end

    if minigameNum == 2 then
        self.room = Room(4, "images/rooms/canoeing/room4")
    end

    self.room:add()
end

function Manager:canoeSwitch(scene)
    self.room = scene
    gfx.sprite.removeAll()
    local canoe = Canoe(200, 200)
    canoe:getRoom(self.room)
    self.room:add()
end

--[[Source: https://www.youtube.com/watch?v=3LoMft137z8]] --

---------------------------------------------------------
--SCENE TRANSITIONS--
---------------------------------------------------------

--[[function Manager:startTransition()
    local transitionTimer = self:fadeTransition(0, 1)

    transitionTimer.timerEndedCallback = function()
        transitionTimer = self:fadeTransition(1, 0)
        transitionTimer.timerEndedCallback = function()
            self.transitioning = false
        end
    end
end

function Manager:fadeTransition(startValue, endValue)
    local transitionSprite = self:createTransitionSprite()
    transitionSprite:setImage(self:getFadedImage(startValue))

    local transitionTimer = pd.timer.new(self.transitionTime, startValue, endValue, pd.easingFunctions.inOutCubic)
    transitionTimer.updateCallback = function(timer)
        transitionSprite:setImage(self:getFadedImage(timer.value))
    end
    return transitionTimer
end

function Manager:getFadedImage(alpha)
    local fadedImage = gfx.image.new(400, 240)
    gfx.pushContext(fadedImage)
    local filledRect = gfx.image.new(400, 240, gfx.kColorBlack)
    filledRect:drawFaded(0, 0, alpha, gfx.image.kDitherTypeBayer8x8)
    gfx.popContext()
    return fadedImage
end--]]
