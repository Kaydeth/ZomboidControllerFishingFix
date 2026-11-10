ISFishingCursor = ISSelectCursor:derive("ISFishingCursor")

function ISFishingCursor:isValid(square)
	if(self.ui.cursor == nil) then
		return false;
	end

	return Fishing.Utils.isValidCastLocation(self.character, square:getX(), square:getY())
end

function ISFishingCursor:getAPrompt()
    if self.canBeBuild then
        return getText("ContextMenu_FoodType_Fish")
    end
    return nil
end

function ISFishingCursor:getBPrompt()
    return getText("UI_Cancel")
end

function ISFishingCursor:getLBPrompt()
    return nil
end

function ISFishingCursor:getRBPrompt()
    return nil
end

function ISFishingCursor:onJoypadPressButton(joypadIndex, joypadData, button)
    local game_ver = getCore():getGameAndBuildVersion();

    if game_ver == "42.22.2" and button == Joypad.AButton then
        self:create(self.xJoypad, self.yJoypad, self.zJoypad, self.north, self.sprite)
    else
        ISBuildingObject.onJoypadPressButton(self, joypadIndex, joypadData, button)
    end
end