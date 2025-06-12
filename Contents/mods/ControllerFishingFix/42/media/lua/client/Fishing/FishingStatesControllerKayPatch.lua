require "Fishing/FishingStates"

function Fishing.States.Idle:update()
    if Fishing.Utils.isPlayerAimOnWater(self.manager.player) then
        Fishing.Utils.facePlayerToAim(self.manager.player)

        if Fishing.Utils.isCastButtonPressed(self.manager.joypad) then
            -- self.manager:changeState("Cast")
            self.manager:changeState("PreCast")
        end
    else
        self.manager:changeState("None")
    end
end

Fishing.States.PreCast = {}
function Fishing.States.PreCast:new(manager)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.manager = manager
    return o
end

function Fishing.States.PreCast:start()
    if(self.manager.joypad ~= -1) then
        Fishing.Utils.clearAimingGridSquare(self.manager.joypad)
        self.cursor = ISFishingCursor:new(self.manager.player, self, self.onSquareSelected)
        self.cursor.isYButtonResetCursor = true;
        local castGridSquare = Fishing.Utils.getLastCastSquare(self.manager.player, self.manager.joypad)
        if(castGridSquare ~= nil) then
            self.cursor.xJoypad = castGridSquare:getX()
            self.cursor.yJoypad = castGridSquare:getY()
        end
        getCell():setDrag(self.cursor, self.manager.player:getPlayerNum())
    end
end

function Fishing.States.PreCast:update()
    if(self.manager.joypad == -1 or self.cursor == nil) then
        if Fishing.Utils.isValidCastLocation(self.manager.player)  then
                self.manager:changeState("Cast")
        else
            if(self.manager.joypad == -1) then
                self.manager:changeState("Idle")
            else
                Fishing.Utils.clearAimingGridSquare(self.manager.joypad)
                self.manager:changeState("None")
            end
        end
    end
end

function Fishing.States.PreCast:stop()
    self.cursor = nil
end

function Fishing.States.PreCast:onSquareSelected(square)
	self.cursor = nil;
    Fishing.Utils.setAimingGridSquare(self.manager.joypad, square)
end

function Fishing.States.Cast:start()
    self.manager.fishingRod:cast()

    if self.manager.joypad ~= -1 then
        Fishing.Utils.saveLastCastGridSquare(self.manager.joypad)
        Fishing.Utils.clearAimingGridSquare(self.manager.joypad)
    end
    self.manager.player:setFishingStage("Cast")
    self.sound = self.manager.player:playSound("CastFishingLine")
end
