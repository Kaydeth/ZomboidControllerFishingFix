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
