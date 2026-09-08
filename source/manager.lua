local pd <const> = playdate
local gfx <const> = pd.graphics

Manager = {}

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
