local pd <const> = playdate
local gfx <const> = pd.graphics

Manager = {}


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
