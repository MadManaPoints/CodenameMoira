local pd <const> = playdate
local gfx <const> = pd.graphics

Manager = {}

Trackers =
{
    ["day"] = {},
    ["night"] =
    {
        ["night1"] =
        {
            ["rooms"] =
            {
                ["room1"] =
                {
                    id = 1,
                    up = nil,
                    down = 3,
                    left = 2,
                    right = nil
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
                    ["brambles"] = { false, false, false },
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

function Manager:switchScene(scene, x, y, isPlayerOne, currentDir, roomCheck)
    self.room = scene
    self:loadNewScene(x, y, isPlayerOne, currentDir, roomCheck)
end

function Manager:startMinigame(minigameNum)
    local x1, y1, x2, y2
    if minigameNum == 1 then
        x1 = 370; y1 = 100
        x2 = 50; y2 = 30

        self.room = Room(6, "images/rooms/night1/room6", false)
    end
    self:loadMinigame(x1, y1, x2, y2, minigameNum)
end

function Manager:loadNewScene(x, y, isPlayerOne, currentDir, roomCheck)
    gfx.sprite.removeAll() -- clear sprites before drawing new scene
    self.room:add()        -- adds scene set as argument in transition

    CurrentCheckpointX = x
    CurrentCheckpointY = y

    if not isPlayerOne then
        Tati = P2(x, y, true, false, currentDir, roomCheck)
    else
        Manny = P1(x, y, true, true, currentDir, roomCheck)
    end
end

function Manager:loadMinigame(x1, y1, x2, y2, minigameNum)
    gfx.sprite.removeAll()
    self.room:add()

    CurrentCheckpointX = x2
    CurrentCheckpointY = y2

    Tati = P2(x2, y2, true, false)
    Manny = P1(x1, y1, true, true)

    if minigameNum == 1 then
        Manny:logMinigame()
    end
end
