local bdr, c, f = select(2, ...):unpack()

local fight = bdr:NewFight(2051, "Kil'Jaeden")

fight.timings = {}
fight.timings['1'] = {
	['8'] = 'Soaks then reflections',
	['8'] = 'Soaks then reflections',
}
fight.timings['1.5'] = {

}
fight.timings['2'] = {

}
fight.timings['2.5'] = {

}
fight.timings['3'] = {

}

fight:Module_AlertText(fight.timings)

fight:OnStart(function()
	fight.phase = '1';
	fight:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)
fight:OnEnd(function()
	fight.phase = '0';
	fight:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)

fight:SetScript("OnEvent",function(self,event,...)
	if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		timeStamp, subevent, hideCaster, sourceGUID, sourceName, 
		sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
		spellID, spellName, spellSchool, amount = ...
		
		if (subevent == "SPELL_AURA_APPLIED" and spellName == "Nether Gale") then
			fight.phase = "1.5"
		end
		
		if (subevent == "SPELL_AURA_REMOVED" and spellName == "Nether Gale") then
			fight.phase = "2"
		end
		
		if (subevent == "SPELL_CAST_SUCCESS" and spellName == "Deceiver's Veil") then
			fight.phase = "2.5"
		end
		
		if (subevent == "SPELL_AURA_REMOVED" and spellName == "Deceiver's Veil") then
			fight.phase = "3"
		end
		
	end
end)