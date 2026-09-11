-- **SOURCE: Playdate SDK Examples** --
-- A lot of the code here is stripped from the pathfinding example located in the Playdate SDK folder --

local pd <const> = playdate
local gfx <const> = pd.graphics

Pathfinding = {}

local abs = math.abs
local function generate2DGraph() end

local w = 16
local h = 10

local useDiagonals = false

local path, startNode, endNode


local heuristicFunction = nil

local grid =
{
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
}

class('Pathfinding').extends(gfx.sprite)

function Pathfinding:init()
    self:setZIndex(100)
    self.graph = pd.pathfinder.graph.new2DGrid(w, h, useDiagonals, grid)
    self:add()
end

local test = 1

function Pathfinding:update()
    --startNode = self.graph:nodeWithXY(test, 5)
    --endNode = self.graph:nodeWithXY(w, h)
    --path = self.graph:findPath(startNode, endNode, heuristicFunction)
end

function Pathfinding:drawGrid()
    gfx.setColor(gfx.kColorBlack)
    gfx.setLineWidth(1)

    -- draw gridLines
    for x = 1, w do
        --gfx.drawLine(x * 25, 0, x * 25, h * 25)
    end

    for y = 1, h do
        --gfx.drawLine(0, y * 24, w * 25, y * 24)
    end
end

local function drawPath(nodes)
    gfx.setColor(gfx.kColorBlack)

    for i = 1, #nodes do
        local n = nodes[i]
        gfx.fillRoundRect((n.x - 1) * 25 + 6, (n.y - 1) * 24 + 6, 9, 9, 2)
    end
end


function Pathfinding:updatePath()
    if path ~= nil then
        --drawPath(path)
    end
end
