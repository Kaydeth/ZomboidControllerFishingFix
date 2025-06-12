ISFishingCursor = ISSelectCursor:derive("ISFishingCursor")

function ISFishingCursor:isValid(square)
	if(self.ui.cursor == nil) then
		return false;
	end

	return Fishing.Utils.isValidCastLocation(self.character, square:getX(), square:getY())
end
