require "Fishing/FishingHandler"

function Fishing.Handler.handleFishing(player, primaryHandItem)
    local playerIndex = player:getPlayerNum()

    if Fishing.Handler.isFishingValid(primaryHandItem) then
        -- if player:getJoypadBind() ~= -1 then
        --     player:Say("Fishing by gamepad not implemented yet")
        --     return
        -- end
        if Fishing.ManagerInstances[playerIndex] == nil then
            Fishing.ManagerInstances[playerIndex] = Fishing.FishingManager:new(player, player:getJoypadBind())
            --getCore():setZoomEnalbed(false)
        end
    else
        if Fishing.ManagerInstances[playerIndex] ~= nil then
            Fishing.ManagerInstances[playerIndex]:destroy()
            Fishing.ManagerInstances[playerIndex] = nil
        end
    end
end