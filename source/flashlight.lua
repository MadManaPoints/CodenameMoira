local pd <const> = playdate
local gfx <const> = pd.graphics

Flashlight = {}

local offsetX, offsetY = 0, 0

class('Flashlight').extends(gfx.sprite)

function Flashlight:init(r)
    self:moveTo(100, 100)
    local flashlightImg = gfx.image.new(r * 2, r * 2)
    gfx.pushContext(flashlightImg)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillCircleAtPoint(r, r, r)
    gfx.popContext()
    self:setImage(flashlightImg)
    self:setCollideRect(10, 10, 100, 100)
    self:setZIndex(30)
    self.speed = 5.0
    self.ySpeed = 2.0
    self.isOut = false
    self:add()
    local bg = DarkBG()
end

function Flashlight:update()
    -- Temp room switch --
    if pd.buttonJustPressed(pd.kButtonB) then
        gfx.setDrawOffset(0, 0)
        GAME_MANAGER:switchScene
        (
            Room(1, "images/rooms/day1/room1"), 100, 100, true, false
        ) --]]
    end

    --move sprite behind background when docked
    if pd.isCrankDocked() then
        self:setZIndex(-1)
        self.isOut = false
    else
        if self:getZIndex() ~= 30 then self:setZIndex(30) end
        self.isOut = true
    end

    -- moves player around screen using crank input
    local crank = pd.getCrankPosition()
    local crankR = math.rad(crank) -- radians... who knew?!

    local newX = math.cos(crankR) * 180
    local goalX = newX + 200 - offsetX
    local newY = math.sin(crankR) * 80
    local goalY = newY + 110 - offsetY

    -- moves camera along with player (offsets are backward for some reason)
    if pd.buttonIsPressed(pd.kButtonLeft) then
        offsetX += self.speed
    end
    if pd.buttonIsPressed(pd.kButtonRight) then
        offsetX -= self.speed
    end

    if pd.buttonIsPressed(pd.kButtonUp) and offsetY < 40 then
        offsetY += self.ySpeed
    end
    if pd.buttonIsPressed(pd.kButtonDown) and offsetY > -40 then
        offsetY -= self.ySpeed
    end
    gfx.setDrawOffset(offsetX, offsetY)

    local x, y, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)


    -- handles individual collisions to check whether player is hovering over object
    --[[
    local X, Y, collisions, numberOfCollisions = self:moveWithCollisions(goalX, goalY)
	for i = 1, numberOfCollisions do
		local collision = collisions[i]

		local collidedSprite = collision.other
		local collisionTag = collidedSprite:getTag()

		-- if only colliding with background, hovering is false
		if collisionTag == TAGS.obstacle then
			self.hovering = true
			if pd.buttonJustPressed(pd.kButtonA) then
				collidedSprite.held = true
			end
		elseif collisionTag == TAGS.bg then
			self.hovering = false
		end
	end
    --]]
end

function Flashlight:collisionResponse(other)
    return 'overlap'
end

DarkBG = {}

class("DarkBG").extends(gfx.sprite)

function DarkBG:init()
    local bg = gfx.image.new(400 * 4, 320);
    gfx.pushContext(bg);
    gfx.fillRect(0, 0, 400 * 4, 320);
    gfx.popContext()
    self:setImage(bg)
    self:moveTo(200, 120)
    self:setCollideRect(0, 0, self:getSize())
    self:add()
end
