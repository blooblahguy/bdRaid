local bdr, c, f = select(2, ...):unpack()

bdr.controller = CreateFrame("frame",nil,UIParent)
local cont = bdr.controller

cont.currentFight = nil

cont.timers = {}

cont:RegisterEvent("ENCOUNTER_START")
cont:RegisterEvent("ENCOUNTER_END")
local total = 0;
function ticker_OnUpdate(self, elapsed)
	local fight = cont.currentFight
	total = total + elapsed
	if (total >= .1 and fight) then
		timers[fight.phase] = timers[fight.phase] or 0
		timers[fight.phase] = timers[fight.phase] + .1
		timers['total'] = timers['total'] + .1
		
		total = 0;
	end
end

cont:SetScript('OnEvent', function(self, event, ...)
	if (event == "ENCOUNTER_START") then
		local encounterID, encounterName, difficultyID
		if (bdr.fights[encounterID]) then
		
			bdr:triggerEvent("fightStart_"..encounterID, difficultyID)
			local fight = bdr.fights[encounterID]
			fight.name = encounterName
			fight.difficulty = difficultyID
			
			ticker:SetScript("OnUpdate", ticker_OnUpdate)
		end
	elseif (event == "ENCOUNTER_END") then
		local encounterID, encounterName, difficultyID
		if (bdr.fights[encounterID]) then
		
			bdr:triggerEvent("fightEnd_"..encounterID, difficultyID)
			
			ticker:SetScript("OnUpdate", function() return end)
		end
	end
end)

function bdr:NewFight(ID, name)
	local fight = CreateFrame("frame", nil, UIParent)
	fight.name = name
	fight.active = false
	fight.phase = "0"
	
	-- initialize helper functions
	function fight:OnStart(func)
		cont.currentFight = fight
		fight.active = true
		bdr:hookEvent("fightStart_"..ID, func)
	end
	function fight:OnEnd(func)
		cont.currentFight = nil
		fight.active = false
		bdr:hookEvent("fightEnd_"..ID, func)
	end
	function fight:OnBossMessage(contains, func)
		bdr:onBossMessage(contains, func)
	end
	
	return fight
end

-- Collect Specialization/Role info
bdr.specs = {}
bdr.specs[66] = "tank" --Paladin: Protection
bdr.specs[73] = "tank" --Warrior: Protection
bdr.specs[104] = "tank" --Druid: Guardian
bdr.specs[250] = "tank" --Death Knight: Blood
bdr.specs[268] = "tank" --Monk: Brewmaster
bdr.specs[581] = "tank" --Demon Hunter: Vengeance

bdr.specs[70] = "melee" --Paladin: Retribution
bdr.specs[71] = "melee" --Warrior: Arms
bdr.specs[72] = "melee" --Warrior: Fury
bdr.specs[103] = "melee" --Druid: Feral
bdr.specs[251] = "melee" --Death Knight: Frost
bdr.specs[252] = "melee" --Death Knight: Unholy
bdr.specs[255] = "melee" --Hunter: Survival
bdr.specs[259] = "melee" --Rogue: Assassination
bdr.specs[260] = "melee" --Rogue: Combat
bdr.specs[261] = "melee" --Rogue: Subtlety
bdr.specs[263] = "melee" --Shaman: Enhancement
bdr.specs[269] = "melee" --Monk: Windwalker
bdr.specs[577] = "melee" --Demon Hunter: Havoc

bdr.specs[62] = "ranged" --Mage: Arcane
bdr.specs[63] = "ranged" --Mage: Fire
bdr.specs[64] = "ranged" --Mage: Frost
bdr.specs[102] = "ranged" --Druid: Balance
bdr.specs[253] = "ranged" --Hunter: Beast Mastery
bdr.specs[254] = "ranged" --Hunter: Marksmanship
bdr.specs[258] = "ranged" --Priest: Shadow
bdr.specs[262] = "ranged" --Shaman: Elemental
bdr.specs[265] = "ranged" --Warlock: Affliction
bdr.specs[266] = "ranged" --Warlock: Demonology
bdr.specs[267] = "ranged" --Warlock: Destruction

bdr.specs[65] = "healer" --Paladin: Holy
bdr.specs[105] = "healer" --Druid: Restoration
bdr.specs[264] = "healer" --Shaman: Restoration
bdr.specs[256] = "healer" --Priest: Discipline
bdr.specs[257] = "healer" --Priest: Holy
bdr.specs[270] = "healer" --Monk: Mistweaver

bdr.playerSpecs = {}
bdr.playerRoles = {}
bdr.roles = {}
bdr.roles.tanks = {}
bdr.roles.melee = {}
bdr.roles.ranged = {}
bdr.roles.healers = {}

bdr.specSnipe = CreateFrame("frame",nil)
bdr.specSnipe:RegisterEvent("ENCOUNTER_START")
bdr.specSnipe:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
bdr.specSnipe:RegisterEvent("PLAYER_ENTERING_WORLD")
bdr.specSnipe:SetScript("OnEvent", function() 
	local specID = GetSpecialization()
	local name = UnitName("player")
	bdr:sendAction("updateSpec", name, specID)
end)
bdr:hookEvent("updateSpec", function(name, specID)
	local role = bdr.specs[specID]
	
	bdr.playerSpecs[name] = specID
	bdr.playerRoles[name] = role
	
	-- remove old role assignments
	bdr.roles.tanks[name] = nil
	bdr.roles.healers[name] = nil
	bdr.roles.melee[name] = nil
	bdr.roles.ranged[name] = nil
	
	-- add to new role
	bdr.roles[role][name] = true
end)

bdr:RegisterEvent("CHAT_MSG_ADDON")
bdr:SetScript("OnEvent", function(self, event, prefix, message, channel, sender)
	if (event == "CHAT_MSG_ADDON" and prefix == bdr.prefix) then
	
		local params = {strsplit("><", message)}
		local action = params[0] or message;
		
		-- the numbers were made strings by the chat_msg_addon, lets find our numbers and convert them tonumbers
		for p = 0, #params do
			local test = params[p]
			if (tonumber(test)) then
				params[p] = tonumber(params[p])
			end
			if (test == nil or test == "") then
				params[p] = ""
			end
		end
		
		params = unpack(params) or params;
		print(params)
		
		bdr:triggerEvent(action, params)
	end
end)