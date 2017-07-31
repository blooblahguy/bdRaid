local bdr, c, f = select(2, ...):unpack()

bdr:RegisterEvent("ADDON_LOADED")
bdr:SetScript("OnEvent", function(self, event, arg1, arg2, ...)
	if (event == "ADDON_LOADED" and arg1 == "bdRaid") then
	
		
	
		bdr:triggerEvent("bdr_loaded")
	end
end)