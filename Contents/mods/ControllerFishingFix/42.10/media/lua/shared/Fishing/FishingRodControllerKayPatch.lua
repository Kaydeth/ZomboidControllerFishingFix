require "Fishing/FishingRod"
local FishingRod = Fishing.FishingRod

local orig_new = FishingRod.new
function FishingRod:new(player)
    o = orig_new(self, player)
    o.joypad = player:getJoypadBind()
    return o
end

local orig_isReel = FishingRod.isReel
function FishingRod:isReel()
    if self.joypad ~= -1 then
         return isJoypadRTPressed(self.joypad) and not isJoypadLTPressed(self.joypad)
    end

    return orig_isReel(self)
end

local orig_isReleaseLine = FishingRod.isReleaseLine
function FishingRod:isReleaseLine()
    if self.joypad ~= -1 then
         return isJoypadLTPressed(self.joypad)
    end

    return orig_isReleaseLine(self)
end

function FishingRod:getRodDxDy()
    if self.bobber == nil then return 0, 0 end

    local bobberX = self.bobber:getX()
    local bobberY = self.bobber:getY()
    local aimX = bobberX + 0.2
    local aimY = bobberY + 0.2
    if self.joypad == -1 then
        -- I don't understand this math. Why should the mouse cursor position effect the length of the fishing rod?
        -- For controller I'm just going to default to mimic if you kept the cursor over the bobber the whole
        -- time you were reeling it in
        aimX, aimY = Fishing.Utils.getAimCoords(self.player, Fishing.actionProperties.defaultLineLen)
    end
    local charX = self.player:getX()
    local charY = self.player:getY()
    ---------
    local vecToBobberX = bobberX - charX
    local vecToBobberY = bobberY - charY
    local vecToBobberLen = IsoUtils.DistanceTo(0, 0, vecToBobberX, vecToBobberY)

    local vecToBobberPerpendicularX = 1
    local vecToBobberPerpendicularY = -(vecToBobberX/vecToBobberY)
    local vecToBobberPerpendicularLen = IsoUtils.DistanceTo(0, 0, vecToBobberPerpendicularX, vecToBobberPerpendicularY)

    local vecToAimX = aimX - bobberX
    local vecToAimY = aimY - bobberY
    local vecToAimLen = IsoUtils.DistanceTo(0, 0, vecToAimX, vecToAimY)

    local dx = (vecToAimX*vecToBobberPerpendicularX + vecToAimY*vecToBobberPerpendicularY)/vecToBobberPerpendicularLen
    local dy = (vecToAimX*vecToBobberX + vecToAimY*vecToBobberY)/vecToBobberLen
    local dLen = IsoUtils.DistanceTo(0, 0, dx, dy)
    if dLen ~= 0 then
        dx = dx / dLen
        dy = dy / dLen
    end

    if bobberY < charY then
        dx = -dx
    end

    local coeff = 1
    if vecToAimLen < 3 then
        coeff = vecToAimLen / 3.0
        -- print("coeff is ", coeff)
    end

    return -dx*coeff, -dy*coeff
end