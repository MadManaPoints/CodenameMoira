local pd <const> = playdate
local gfx <const> = pd.graphics

Manager = {}

class('Manager').extends()

function Manager:switchScene(scene, x, y, isPlayerOne)
    self.room = scene
    self:loadNewScene(x, y, isPlayerOne)
end

function Manager:loadNewScene(x, y, isPlayerOne)
    gfx.sprite.removeAll() -- clear sprites before drawing new scene
    self.room:add()        -- adds scene set as argument in transition

    CurrentCheckpointX = x
    CurrentCheckpointY = y

    if not isPlayerOne then
        Tati = P2(x, y, true, false)
    else
        Manny = P1(x, y, true, true)
    end
end
