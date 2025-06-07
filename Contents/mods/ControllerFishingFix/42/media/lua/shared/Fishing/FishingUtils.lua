Fishing = Fishing or {}
Fishing.Utils = {}

function Fishing.Utils.isWaterCoords(x, y)
    local sq = getCell():getGridSquare(x, y, 0)
    if sq and sq:getProperties() and sq:getProperties():Is(IsoFlagType.water) then
        return true
    end
    return false
end

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
    print "Clear cached aim"
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

function Fishing.Utils.getAimCoords(player)
    local joypad = player:getJoypadBind()
    if joypad == -1 then
        return ISCoordConversion.ToWorld(getMouseXScaled(), getMouseYScaled() + 100, player:getZ())
    else
        local aim = Fishing.Utils.ControllerAim[joypad]
        return aim.gridSquare:getX(), aim.gridSquare:getY()
    end
end

Fishing.Utils.stopFishingKeysKeyboard = { "Forward", "Left", "Backward", "Right", "Melee", "CancelAction" }
function Fishing.Utils.isStopFishingButtonPressed(joypad)
    if joypad == -1 then
        for _, key in ipairs(Fishing.Utils.stopFishingKeysKeyboard) do
            if isKeyPressed(key) then
                if getCore():getKey(key) then
                    GameKeyboard.eatKeyPress(getCore():getKey(key))
                elseif getCore():getAltKey(key) then
                    GameKeyboard.eatKeyPress(getCore():getAltKey(key))
                end
                return true
            end
        end
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

Fishing.Utils.tempVec2 = Vector2.new()
function Fishing.Utils.facePlayerToAim(player)
    local vec = player:getAimVector(Fishing.Utils.tempVec2)
    player:faceLocationF(player:getX() + vec:getX(), player:getY() + vec:getY())
end

function Fishing.Utils.FacePlayerToBobber(player, x, y)
    player:faceLocationF(x, y)
end

function Fishing.Utils.isCastButtonPressed(joypad)
    if joypad == -1 then
        return isMouseButtonDown(0)
    else
        return isJoypadRTPressed(joypad)
        -- return isJoypadPressed(joypad, getJoypadRightStickButton(joypad))
    end
end

function Fishing.Utils.isNearShore(x, y)
    local cell = getCell()
    for i = -7, 7 do
        for j = -7, 7 do
            local sq = cell:getGridSquare(math.floor(x+i), math.floor(y+j), 0)
            if sq ~= nil and sq:getWater() ~= nil and sq:getWater():isActualShore()  then
                return true
            end
        end
    end
    return false
end

-- Small, Medium, Big
Fishing.Utils.fishSizeChancesBySkillLevel = {}
Fishing.Utils.fishSizeChancesBySkillLevel[0] = { 95, 5, 0 }
Fishing.Utils.fishSizeChancesBySkillLevel[1] = { 85, 15, 0 }
Fishing.Utils.fishSizeChancesBySkillLevel[2] = { 75, 24, 1 }
Fishing.Utils.fishSizeChancesBySkillLevel[3] = { 70, 25, 5 }
Fishing.Utils.fishSizeChancesBySkillLevel[4] = { 60, 30, 10 }
Fishing.Utils.fishSizeChancesBySkillLevel[5] = { 48, 40, 12 }
Fishing.Utils.fishSizeChancesBySkillLevel[6] = { 35, 45, 20 }
Fishing.Utils.fishSizeChancesBySkillLevel[7] = { 25, 45, 30 }
Fishing.Utils.fishSizeChancesBySkillLevel[8] = { 20, 40, 40 }
Fishing.Utils.fishSizeChancesBySkillLevel[9] = { 15, 40, 45 }
Fishing.Utils.fishSizeChancesBySkillLevel[10] = { 10, 40, 50 }

function Fishing.Utils.getFishSizeChancesBySkillLevel(lvl, isNearShore, fishNum)
    if fishNum == 0 then
        return 100, 0, 0
    end
    local fishSmall = Fishing.Utils.fishSizeChancesBySkillLevel[lvl][1]
    local fishMedium = Fishing.Utils.fishSizeChancesBySkillLevel[lvl][2]
    local fishBig = Fishing.Utils.fishSizeChancesBySkillLevel[lvl][3]

    if isNearShore then
        fishSmall = fishSmall + fishMedium/2 + fishBig/2
        fishMedium = fishMedium / 2
        fishBig = fishBig / 2
    end

    return fishSmall, fishMedium, fishBig
end


----- Fishing params and coeffs -----

function Fishing.Utils.getTemperatureParams(player)
    local temperature = getClimateManager():getAirTemperatureForCharacter(player, false)
    local temperatureCoeff = 1
    if temperature >= 30 and temperature < 40 or temperature >= 0 and temperature < 15 then
        temperatureCoeff = 0.75
    elseif temperature >= 40 or temperature > -10 and temperature < 0 then
        temperatureCoeff = 0.5
    elseif temperature <= -10 then
        temperatureCoeff = 0.25
    end

    return { temperature = temperature, coeff = temperatureCoeff }
end

function Fishing.Utils.getWeatherParams()
    local weatherCoeff = 1
    local isFog = getClimateManager():getFogIntensity() >= 0.4
    local isWind = getClimateManager():getWindPower() >= 0.5
    local isRain = RainManager.isRaining()

    if isFog or isWind then
        weatherCoeff = 0.8
    elseif isRain then
        weatherCoeff = 1.2
    end

    return { isFog = isFog, isWind = isWind, isRain = isRain, coeff = weatherCoeff }
end

function Fishing.Utils.getTimeParams()
    local currentHour = math.floor(math.floor(GameTime.getInstance():getTimeOfDay() * 3600) / 3600);
    local timeCoeff = 1
    if (currentHour >= 4 and currentHour <= 6) or (currentHour >= 18 and currentHour <= 20) then
        timeCoeff = 1.2
    end

    return { time = currentHour, coeff = timeCoeff }
end

function Fishing.Utils.getHookParams(hookType)
    local hookCoeff = 1
    if hookType == nil or Fishing.hook[hookType] == nil then
        hookCoeff = 0
    else
        hookCoeff = Fishing.hook[hookType]
    end

    return { hook = hookType, coeff = hookCoeff }
end

function Fishing.Utils.getFishNumParams(x, y)
    local numberOfFish = FishSchoolManager.getInstance():getFishAbundance(x, y)
    local numberOfFishCoeff = 1
    if numberOfFish == 0 then
        numberOfFishCoeff = 0.1
    elseif numberOfFish < 10 then
        numberOfFishCoeff = 0.5
    elseif numberOfFish <= 25 then
        numberOfFishCoeff = 1.0
    else
        numberOfFishCoeff = 1.5
    end

    return { value = numberOfFish, coeff = numberOfFishCoeff }
end


---

local function fishGroupsUpdate()
    FishSchoolManager.getInstance():updateSeed()
end
Events.EveryDays.Add(fishGroupsUpdate)
