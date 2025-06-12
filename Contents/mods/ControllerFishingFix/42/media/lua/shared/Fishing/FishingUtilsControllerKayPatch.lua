require "Fishing/FishingUtils"

Fishing.Utils.ControllerAim = {}
function Fishing.Utils.setAimingGridSquare(joypad, gridSquare)
    local aim = Fishing.Utils.ControllerAim[joypad]
    if aim == nil then
        aim = {}
        Fishing.Utils.ControllerAim[joypad] = aim
    end
    aim.gridSquare = gridSquare
end

function Fishing.Utils.clearAimingGridSquare(joypad)
    Fishing.Utils.ControllerAim[joypad] = nil
end

Fishing.Utils.ControllLastCast = {}
function Fishing.Utils.saveLastCastGridSquare(joypad)
    Fishing.Utils.ControllLastCast[joypad] = Fishing.Utils.ControllerAim[joypad].gridSquare
end

function Fishing.Utils.clearLastGridSquare(joypad)
end

function Fishing.Utils.getLastCastSquare(player, joypad)
    local square = Fishing.Utils.ControllLastCast[joypad]

    if square ~= nil then
        if Fishing.Utils.isAccessibleAimDist(player,square:getX(),square:getY()) and square:isCanSee(player:getIndex()) then
                return square
        end
        Fishing.Utils.ControllLastCast[joypad] = nil
    end
    return nil
end

local orig_getAimCoords = Fishing.Utils.getAimCoords
function Fishing.Utils.getAimCoords(player)
    local joypad = player:getJoypadBind()
    if joypad == -1 then
        return orig_getAimCoords(self,player)
    else
        local aim = Fishing.Utils.ControllerAim[joypad]
        return aim.gridSquare:getX(), aim.gridSquare:getY()
    end
end

local orig_isStopFishingButtonPressed = Fishing.Utils.isStopFishingButtonPressed
function Fishing.Utils.isStopFishingButtonPressed(joypad)
    if joypad == -1 then
        return orig_isStopFishingButtonPressed(self, joypad)
    else
        if getJoypadMovementAxisX(joypad) ~= 0 or getJoypadMovementAxisY(joypad) ~= 0 or isJoypadPressed(joypad, getJoypadBButton(joypad)) then
            return true
        end
    end
    return false
end

function Fishing.Utils.isPlayerAimOnWater(player, autoAim)
    if (not player:isAiming() and not autoAim) then return false end

    local joypad = player:getJoypadBind()
    if(joypad == -1) then
        local x, y = Fishing.Utils.getAimCoords(player)
        return Fishing.Utils.isLocationOnWater(x,y)
    else
        if(not player:isAiming()) then return false end

        --See if there is a water square visible where the player is aiming
        -- North is towards the upper right of the screen
        -- Y goes down as you move north
        -- X goes down as you move west
        local fishingRadius = 16
        local plX, plY = player:getX(), player:getY()
        local dir = player:getDir()
        local x1, x2, y1, y2 = 0,0,0,0
        if     dir == IsoDirections.N  then   x1,x2,y1,y2 = plX - fishingRadius, plX + fishingRadius, plY - fishingRadius, plY
        elseif dir == IsoDirections.NE then   x1,x2,y1,y2 = plX, plX + fishingRadius, plY - fishingRadius, plY
        elseif dir == IsoDirections.E  then   x1,x2,y1,y2 = plX, plX + fishingRadius, plY - fishingRadius, plY + fishingRadius
        elseif dir == IsoDirections.SE then   x1,x2,y1,y2 = plX, plX + fishingRadius, plY, plY + fishingRadius
        elseif dir == IsoDirections.S  then   x1,x2,y1,y2 = plX - fishingRadius, plX + fishingRadius, plY, plY + fishingRadius
        elseif dir == IsoDirections.SW then   x1,x2,y1,y2 = plX - fishingRadius, plX, plY, plY + fishingRadius
        elseif dir == IsoDirections.W  then   x1,x2,y1,y2 = plX - fishingRadius, plX, plY - fishingRadius, plY + fishingRadius
        elseif dir == IsoDirections.NW then   x1,x2,y1,y2 = plX - fishingRadius, plX, plY - fishingRadius, plY
        end

        for x = x1, x2 do
            for y = y1, y2 do
                local sq = getSquare(x, y, 0)
                if Fishing.Utils.isLocationOnWater(x,y) and sq:isCanSee(player:getIndex()) then
                    return true
                end
            end
        end

        return false
    end
end

function Fishing.Utils.isLocationOnWater(x,y)
    if Fishing.isNoFishZone(x,y) then
        return false
    end

    local sq = getSquare(x, y, 0)
    if sq and sq:getProperties() and sq:getProperties():Is(IsoFlagType.water) then
        return true
    end
    return false
end

function Fishing.Utils.isValidCastLocation(player)
    local x, y = Fishing.Utils.getAimCoords(player)
    return Fishing.Utils.isLocationOnWater(x,y) and Fishing.Utils.isAccessibleAimDist(player,x,y)
end

function Fishing.Utils.isAccessibleAimDist(player, x,y)
    local distance = IsoUtils.DistanceTo(player:getX(), player:getY(), x, y)

    return distance < 16
    -- return IsoUtils.DistanceTo(player:getX(), player:getY(), x, y) < 16
end

local orig_isCastButtonPressed = Fishing.Utils.isCastButtonPressed
function Fishing.Utils.isCastButtonPressed(joypad)
    if joypad == -1 then
        return orig_isCastButtonPressed(self, joypad)
    else
        return isJoypadRTPressed(joypad)
        -- return isJoypadPressed(joypad, getJoypadRightStickButton(joypad))
    end
end
