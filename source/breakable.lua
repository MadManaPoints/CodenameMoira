local pd <const> = playdate
local gfx <const> = pd.graphics

Breakable = {}

class('Breakable').extends(gfx.sprite)

function Breakable:init(x, y, id, ded)
    self:moveTo(x, y)
    self:setCenter(0, 0)
    local img = gfx.imagetable.new("images/brambles/brambles")
    self.anim = gfx.animation.loop.new(100, img, false)
    self.lastFrame = math.random(2, 4)
    self:setCollideRect(0, 0, 21, 21)
    self:setCollidesWithGroups({ 1, 2, 4 })
    self:setGroups(3)
    self.anim.paused = true
    self.broken = ded
    self.id = id
    if ded then self.anim.frame = self.lastFrame end
    self:setZIndex(4)
    self:setImage(self.anim:image())
    self:add()
end

function Breakable:update()
    if self.broken and self.anim.frame ~= self.lastFrame then
        -- Set specific bramble to broken for scene persistance
        Trackers.night.night1.rooms["room" .. tostring(RoomID)].brambles[self.id] = true
        -- Change sprite to broken brambles
        self.anim.frame = self.lastFrame
        self:setImage(self.anim:image())
    end
end
