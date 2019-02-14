-- format
--[[
	@start kicks Group1 spellName
	Person1/person2, Person3, Person4, Person5/person6
	@end kicks
]]

-- get list from AA
local kickGroups = {}
local kickSpells = {}
local playerAssigned = false

local playerKicks = {}
playerKicks['Rebuke'] = 15

local kt = CreateFrame("frame")
kt:RegisterEvent("NAME_PLATE_UNIT_ADDED")
kt:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
kt:RegisterEvent("ENCOUNTER_START")
kt:RegisterEvent("ENCOUNTER_END")
kt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

--============================================
-- Main Functions
--============================================
function kt:ProcessCombat()
	local timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellID, spellName, spellSchool, extraSpellID, extraSpellName, extraSchool = CombatLogGetCurrentEventInfo();

	if (event == "SPELL_CAST_START") then
		if (not kickSpells[spellName]) then return end

	elseif (event == "SPELL_CAST_SUCCESS") then


	elseif (event == "SPELL_INTERRUPT") then

	end
end

function kt:Activate()
	kickGroups = {}
	kickSpells = {}

	-- Read AA for kicks
	for k,v in pairs(AngryAssign_Pages) do
		if v.Name == aura_env.config.page then
			text = AngryAssign_Pages[k].Contents
			break
		end
	end
	if (not text) then return end

	-- loop through lines
	local group = {}
	for line in text:gmatch("[^\r\n]+") do
		line = strlower(line)

		if string.find(line,"@start kick") ~= nil then
			-- start a new kick group
			local statement, command, name, spellName, spellName2 = strsplit(" ",line)
			group = {}
			group.name = name
			group.current = 1
			group.lastKick = 0
			group.spellName = spellName
			group.spellName2 = spellName2
			kickSpells[spellName] = spellName
			kickSpells[spellName2] = spellName2
			group.kickers = {}
		elseif string.find(line,"@end kick") ~= nil then
			-- end a kick group
			table.insert(kickGroups, group)
		else
			-- presumably players are here now
			local players = {strsplit(" ",line)}
			for k, player in pairs(players) do
				player = strtrim(player)

				-- allow for mutiple assignments per kick
				local player, person2 = strsplit("/", player)
				player = UnitExists(player) and strtrim(player) or false
				person2 = UnitExists(person2) and strtrim(person2) or false

				if (player) then
					-- current player is assigned
					if (UnitIsUnit(player, "player") or (person2 and UnitIsUnit(person2, "player"))) then
						playerAssigned = true
					end

					-- split this assignment
					if (person2) then
						table.insert(group.kickers, {player, person2})
					else
						table.insert(group.kickers, {player})
					end
				end

			end
		end
	end

	-- Build multiple lists of kickers
end
function kt:Deactivate()
	kickGroups = {}
	playerAssigned = false
end

local guid_unit = {}

local displayList = CreateFrame("frame", nil, UIParent)
displayList:SetUserPlaced(true)

kt:SetScript("OnEvent", function(self, event, unit)
	if (event == "ENCOUNTER_START") then
		kt:Activate()
	elseif (event == "ENCOUNTER_END") then
		kt:Deactivate()
	elseif (event == "NAME_PLATE_UNIT_ADDED") then
		guid_unit[UnitGUID(unit)] = unit
	elseif (event == "NAME_PLATE_UNIT_REMOVED") then
		guid_unit[UnitGUID(unit)] = nil
	elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
		kt:ProcessCombat()
	end
end)