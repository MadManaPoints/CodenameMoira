local pd <const> = playdate
local gfx <const> = pd.graphics

Room = {}

local spriteSheet =
{
    waterway = gfx.imagetable.new("images/rooms/night1/room5Table/room5"),
    minigame1 = gfx.imagetable.new("images/rooms/night1/room6Table/room6")
}
local animatedRoom = nil

class('Room').extends(gfx.sprite)

function Room:init(roomNum, img, isAnimated)
    self:setCenter(0, 0)
    self:moveTo(0, 0)
    RoomID = roomNum
    self.roomNumber = RoomID
    if isAnimated then
        if roomNum == 5 then
            animatedRoom = gfx.animation.loop.new(200, spriteSheet.waterway, true)
        else
            animatedRoom = gfx.animation.loop.new(200, spriteSheet.minigame1, true)
        end
        -- temp -- prototype has only one animated room for now --
        self.anim = animatedRoom
        self:setImage(self.anim:image())
    else
        local roomImg = gfx.image.new(img)
        self:setImage(roomImg)
    end
    self.createRoom = false
    self:setZIndex(1)
    self:add()
end

function Room:update()
    if self.anim ~= nil then
        self:setImage(self.anim:image())
    end

    if not self.createRoom then
        self:updateColliders()
        self.createRoom = true
    end
end

function Room:updateColliders()
    --local col1 = Collider(0, 0, 127, 109)
    --local col2 = Collider(0, 185, 127, 55)

    --- LEVEL ONE (NIGHT) ---

    if self.roomNumber == 1 then
        local stump = Collider(141, 131, 24, 6)
        local stumpTrigger = Trigger(144, 140, 18, 4, 280, false, false, false)
        local trees1 = Collider(0, 0, 400, 30)
        local trees2 = Collider(0, 31, 48, 89)
        local trees3 = Collider(38, 212, 81, 28)
        local water1 = Water(0, 121, 37, 119)
        local water2 = Water(38, 121, 82, 92)
        local water3 = Water(49, 31, 71, 90)
        local cliff1 = Collider(121, 182, 278, 58)
        local border1 = Collider(400, 0, 5, 240)
        local border2 = Collider(0, 241, 38, 5)

        local treePath1 = WorldObject(200, 120, "images/worldObjects/treePath1", 4)
        local treePath2 = WorldObject(200, 120, "images/worldObjects/treePath2", 10)
        local border4 = Collider(260, 20, 140, 52)
        local border5 = Collider(260, 135, 140, 52)

        local bramble1 = Breakable(260, 80, 1, Trackers.night.night1.rooms.room1.brambles[1])
        local bramble2 = Breakable(260, 101, 2, Trackers.night.night1.rooms.room1.brambles[2])
    end

    if self.roomNumber == 2 then
        local enemy1 = Enemy(182, 80, true, true, true, false)
        local bramble1 = Breakable(269, 34, 1, Trackers.night.night1.rooms.room2.brambles[1])
        local bramble2 = Breakable(269, 55, 2, Trackers.night.night1.rooms.room2.brambles[2])
        local bramble3 = Breakable(269, 76, 3, Trackers.night.night1.rooms.room2.brambles[3])
        local bramble4 = Breakable(294, 34, 4, Trackers.night.night1.rooms.room2.brambles[4])
        local bramble5 = Breakable(294, 55, 5, Trackers.night.night1.rooms.room2.brambles[5])
        local bramble6 = Breakable(294, 76, 6, Trackers.night.night1.rooms.room2.brambles[6])
        local bramble7 = Breakable(153, 177, 7, Trackers.night.night1.rooms.room2.brambles[7])
        local bramble8 = Breakable(153, 198, 8, Trackers.night.night1.rooms.room2.brambles[8])
        local trees1 = Collider(0, 0, 400, 30)
        local trees2 = Collider(0, 30, 30, 192)
        local trees3 = Collider(0, 223, 174, 17)
        local trees4 = Collider(378, 31, 22, 90)
        local border1 = Collider(364, 100, 13, 20)
        local border2 = Collider(296, 100, 18, 20)
        local border3 = Collider(83, 127, 220, 45)
        local border4 = Collider(265, 172, 38, 68)
        local border5 = Collider(304, 206, 24, 34)
        local border6 = Collider(329, 241, 71, 5)
        local border7 = Collider(214, 223, 50, 17)
        local water1 = Water(111, 31, 142, 97)
    end

    if self.roomNumber == 3 then
        --local waterfall = Waterfall(28, 57, false)
        local cliff1 = Collider(255, 77, 127, 36)
        local slingshot = Slingshot(125, 150, 1)
        --local jumpTrigger = Trigger(32, 116, 35, 42, 140, false, true)
        local stump = Collider(342, 18, 24, 6)
        local stumpTrigger = Trigger(345, 27, 18, 4, 121, false, false, false)
        local enemy1 = Enemy(210, 205, true, false, false, false, 1, Trackers.night.night1.rooms.room3.enemies[1])
        local enemy2 = Enemy(240, 205, true, false, false, false, 2, Trackers.night.night1.rooms.room3.enemies[2])
        local border1 = Collider(186, 0, 6, 62)
        local border2 = Collider(0, 63, 192, 10)
        local border3 = Collider(0, 109, 67, 5)
        local border4 = Collider(67, 114, 5, 48)
        local border5 = Collider(0, 163, 67, 5)
        local border6 = Collider(188, 77, 36, 33)
        local border7 = Collider(203, 13, 5, 63)
        local border8 = Collider(208, 8, 174, 5)
        local border9 = Collider(382, 13, 5, 63)
        local border10 = Collider(263, 114, 38, 60)
        local border11 = Collider(383, 108, 17, 5)
        local border12 = Collider(401, 113, 5, 127)
        local border13 = Collider(188, 174, 74, 15)
        local border14 = Collider(84, 169, 104, 5)
        local border15 = Collider(185, 110, 5, 63)
        local border16 = Collider(188, 174, 74, 15)
        local border17 = Collider(79, 174, 5, 66)
        local border18 = Collider(157, 227, 243, 13)
        local border19 = Collider(0, -5, 400, 5)
    end

    if RoomID == 4 then
        local enemy1 = Enemy(38, 60, false, false, false, false, 1,
            Trackers.night.night1.rooms.room4.enemies.monster1[1])
        local enemy2 = Enemy(62, 180, false, false, false, false, 2,
            Trackers.night.night1.rooms.room4.enemies.monster2[1])
        local enemy3 = Enemy(213, 132, false, false, false, false, 3,
            Trackers.night.night1.rooms.room4.enemies.monster3[1])

        local cliff1 = Collider(280, 65, 47, 49)
        local stump = Collider(291, 14, 24, 5)
        local stumpTrigger = Trigger(294, 23, 18, 4, 135, false, false, false)
        local border1 = Collider(0, 0, 174, 23)
        local border2 = Collider(214, 0, 22, 23)
        local border3 = Collider(236, 0, 5, 240)
        local border4 = Collider(0, 187, 22, 53)
        local border5 = Collider(100, 187, 136, 53)
        local border6 = Collider(275, 0, 5, 95)
        local border7 = Collider(274, 114, 5, 48)
        local border8 = Collider(279, 163, 121, 5)
        local border9 = Collider(328, 109, 72, 5)
        local border10 = Collider(250, -5, 150, 5)
        local border11 = Collider(-5, 0, 5, 240)
        local willow = WorldObject(113, 109, "images/worldObjects/willowTree.png", 10, false, true)
    end

    if RoomID == 5 then
        local border1 = Collider(79, 0, 5, 107)
        local border2 = Collider(84, 107, 73, 5)
        local border3 = Collider(158, 0, 5, 83)
        local border4 = Collider(359, 84, 19, 16)
        local border5 = Collider(335, 212, 19, 16)
        local border6 = Collider(19, 196, 19, 16)
        local log = LogPole(174, 94, 20, 20, 0, false, false, true)
        local exit = Exit(30, 30, 50, 20, 1)
        --local log1 = WorldObject(174, 94, "images/worldObjects/log")
        --local exit = Collider(35, 32, 40, 30)
    end

    if RoomID == 6 then
        -- Breakable Objects --
        local bramble1 = Breakable(68, 187)
        local bramble2 = Breakable(68, 204)
        local bramble3 = Breakable(170, 28)

        local UI = CharacterSwitchUI()

        -- Enemies --
        local enemy1 = Enemy(88, 85, true, false, false)
        local enemy2 = Enemy(268, 70, true, true, false, false)
        local enemy3 = Enemy(268, 135, true, true, false, true)

        -- Borders --
        local border1 = Collider(0, 0, 18, 240)
        local border2 = Collider(103, 0, 221, 17)
        local border3 = Collider(103, 18, 16, 39)
        local border4 = Collider(79, 58, 40, 12)
        local border5 = Collider(79, 101, 98, 15)
        local border6 = Collider(79, 117, 20, 59)
        local border7 = Collider(304, 18, 20, 162)
        local border8 = Collider(153, 56, 79, 14)
        local border9 = Collider(215, 71, 17, 82)
        local border10 = Collider(160, 154, 72, 14)
        local border11 = Collider(160, 169, 17, 71)
        local border12 = Collider(95, 227, 82, 13)
        local border13 = Collider(304, 221, 20, 19)
        local border14 = Collider(0, -18, 400, 5)
        local border15 = Collider(0, 240, 400, 5)
        local border16 = Collider(400, 0, 5, 240)
        local border17 = Collider(354, 5, 19, 16)
        local water1 = Water(19, 55, 59, 124)
        local water2 = Water(95, 117, 119, 36)
        local water3 = Water(95, 154, 64, 72)
        local water4 = Water(79, 71, 135, 29)
        local water5 = Water(120, 55, 32, 15)
        local water6 = Water(213, 18, 90, 37)
        local water7 = Water(233, 56, 70, 115)
        local water8 = Water(302, 181, 22, 39)
        --local water9 = Water(325, 0, 75, 240)

        -- Triggers --
        local winExit = Exit(340, 100, 48, 48, 0, true, false, true)
        local loseExit = Exit(340, 235, 50, 10, 0, true, true)
    end
end
