require "Fishing/FishingManager"
local FishingManager = Fishing.FishingManager

local orig_initStates = FishingManager.initStates
function FishingManager:initStates()
    self.states["PreCast"] = Fishing.States.PreCast:new(self)
    orig_initStates(self)
end
