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
        Tati = Player(x, y, true, false, 2)
    else
        Manny = Player(x, y, true, true, 1)
    end
end
