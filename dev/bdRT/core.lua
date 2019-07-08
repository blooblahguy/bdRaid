local name, bdrt = ...

-- Don't be mad at us blizzard
local test = false
local hasDebuff = nil
local modules = {}
modules['test'] = {}
modules['test']['Moonfire'] = true
modules['test']['Thrash'] = true
modules['Spellblade Aluriel'] = {}
modules['Spellblade Aluriel']["Mark of Frost"] = true
modules['Spellblade Aluriel']["Searing Brand"] = true

--[[modules['Star Augur Etraeus'] = {}
modules['Star Augur Etraeus']["Star Sign: Crab"] = true
modules['Star Augur Etraeus']["Star Sign: Wolf"] = true
modules['Star Augur Etraeus']["Star Sign: Dragon"] = true
modules['Star Augur Etraeus']["Star Sign: Hunter"] = true--]]

local spellalert = CreateFrame("frame")
spellalert:RegisterEvent("ENCOUNTER_START")
spellalert:RegisterEvent("UNIT_AURA")
spellalert:SetScript("OnEvent",function(self,event,unit,spellname,icon)
	if (event == "ENCOUNTER_START") then
		ChatFrame_RemoveMessageGroup(ChatFrame1, "YELL")
	end
	if (event == "ENCOUNTER_END") then
		ChatFrame_AddMessageGroup(ChatFrame1, "YELL")
	end
	if (not UnitIsUnit("player",unit)) then return end -- only do for yourself
	hasDebuff = nil
	for boss, spells in pairs(modules) do
		if (not (UnitName("boss1") == boss or test)) then return end
		
		-- Loop through the spells
		for spell, duration in pairs(spells) do
			if (UnitDebuff(unit,spell)) then
				hasDebuff = spell
				bdCore:triggerEvent("bdRT_debuff_show")
			end
		end
	end
	
	if (not hasDebuff) then
		bdCore:triggerEvent("bdRT_debuff_hide")	
	end
end)

local function makeBrokenAssIndiator(frame)
	local scale = UIParent:GetEffectiveScale()*1
	
	for i=1, frame:GetNumRegions() do
		local region = select(i, frame:GetRegions())
		if region:GetObjectType() == "Texture" then
			region.defaulttex = region:GetTexture()
			frame.texture = region
		elseif region:GetObjectType() == "FontString" then
			frame.text = region
			frame.string = region:GetText()
			frame.defaultfont, frame.defaultsize = region:GetFont()
		end
	end
	if (not frame.AbilityMark) then
		frame.AbilityMark = CreateFrame("Cooldown",nil,frame,"CooldownFrameTemplate")
		frame.AbilityMark:SetFrameStrata("TOOLTIP")
		frame.AbilityMark:SetFrameLevel(10)
		frame.AbilityMark:SetSize(60,60)
		frame.AbilityMark:SetReverse(true)
		frame.AbilityMark:SetHideCountdownNumbers(true)
		frame.AbilityMark:SetBlingTexture('')
		bdCore:setBackdrop(frame.AbilityMark)
		
		frame.AbilityMark.tex = frame.AbilityMark:CreateTexture(nil,"BORDER")
		frame.AbilityMark.tex:SetAllPoints(frame.AbilityMark)
		frame.AbilityMark.tex:SetTexCoord(0.08, 0.9, 0.08, 0.9)
		
		frame.AbilityMark.text = frame.AbilityMark:CreateFontString(nil,"OVERLAY")
		frame.AbilityMark.text:SetFont(bdCore.media.font,20,"OUTLINE")
		frame.AbilityMark.text:SetJustifyH("CENTER")
		frame.AbilityMark.text:SetText("1")
		frame.AbilityMark.text:SetPoint("CENTER")
		frame.AbilityMark.text:Hide()
	end
	
	local function parseAbilityMark()
		frame.string = frame.text:GetText()
		if (strfind(frame.string, "bd_")) then
			frame.text:SetAlpha(0)
			frame.texture:SetTexture(nil)
			frame:DisableDrawLayer("BACKGROUND")
			frame:DisableDrawLayer("BORDER")
			
			local bd, unit, spell = strsplit("_", frame.string)

			local name, rank, icon, count, dispel, duration, expireTime, caster = UnitDebuff(unit,spell)
			if (name) then
				frame.AbilityMark.tex:SetTexture(icon)
				frame.AbilityMark:SetFrameLevel(10)
				frame.AbilityMark:ClearAllPoints()
				frame.AbilityMark:SetPoint("BOTTOM", frame, "TOP", 0, 0)
				frame.AbilityMark:Show()
				frame.AbilityMark:SetScale(scale)
				frame.AbilityMark:SetAlpha(1)
				frame.AbilityMark:SetCooldown(expireTime - duration, duration)
				
			else
				frame.AbilityMark:Hide()
			end
		else
			frame.text:SetAlpha(1)
			frame.texture:SetTexture(frame.defaulttex)
			frame:EnableDrawLayer("BACKGROUND")
			frame:EnableDrawLayer("BORDER")
			
			if (frame.AbilityMark) then frame.AbilityMark:Hide() end
		end
		
		--[[if (UnitName("boss1") == "Star Augur Etraeus") then
			frame.AbilityMark.text:Show()
			local playermark = select(1, UnitDebuff("player","Star Sign: Crab")) or nil
			playermark = playermark or select(1, UnitDebuff("player","Star Sign: Wolf")) or nil
			playermark = playermark or select(1, UnitDebuff("player","Star Sign: Dragon")) or nil
			playermark = playermark or select(1, UnitDebuff("player","Star Sign: Hunter")) or nil
			
			local platemark = select(1, UnitDebuff(unit,"Star Sign: Crab")) or nil
			platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Wolf")) or nil
			platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Dragon")) or nil
			platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Hunter")) or nil
			
			if (platemark == "Star Sign: Crab") then
				frame.AbilityMark.text:SetText("1")
			elseif (platemark == "Star Sign: Wolf") then
				frame.AbilityMark.text:SetText("2")
			elseif (platemark == "Star Sign: Dragon") then
				frame.AbilityMark.text:SetText("3")
			elseif (platemark == "Star Sign: Hunter") then
				frame.AbilityMark.text:SetText("4")
			end
			
			if (platemark and playermark and platemark == playermark) then -- make green
				local duration = select(6, UnitDebuff(unit, platemark))
				local expiration = select(7, UnitDebuff(unit, platemark))
				frame.AbilityMark.tex:SetTexture(236595)
				frame.AbilityMark:SetFrameLevel(10)
				frame.AbilityMark:Show()
				frame.AbilityMark:SetAlpha(1)
				frame.AbilityMark:SetCooldown(expiration - duration, duration)
			elseif (platemark) then -- make red
				local duration = select(6, UnitDebuff(unit, platemark))
				local expiration = select(7, UnitDebuff(unit, platemark))
				local icon = select(3, UnitDebuff(unit, platemark))
				frame.AbilityMark.tex:SetTexture(236612)
				frame.AbilityMark:SetFrameLevel(12)
				frame.AbilityMark:Show()
				frame.AbilityMark:SetAlpha(1)
				frame.AbilityMark:SetCooldown(expiration - duration, duration)
				if (not playermark and icon) then 
					frame.AbilityMark.tex:SetTexture(icon) 
					frame.AbilityMark:SetAlpha(0.5)
				end
			else
				frame.AbilityMark:Hide()
				frame.AbilityMark.text:Hide()
			end
		end--]]
	end
	
	bdCore:hookEvent("bdRT_debuff_show",parseAbilityMark)
	frame:HookScript("OnShow",parseAbilityMark)
	bdCore:hookEvent("bdRT_debuff_hide",function()
		frame.string = frame.text:GetText()
		if (not strfind(frame.string, "bd_")) then
			frame.text:SetAlpha(1)
			frame.texture:SetTexture(frame.defaulttex)
			frame:EnableDrawLayer("BACKGROUND")
			frame:EnableDrawLayer("BORDER")
		end
		
		if (frame.AbilityMark) then frame.AbilityMark:Hide() end
	end)
end
local function ischatbubble(frame)
	if frame:IsForbidden() then return end
	if frame:GetName() then return end
	if not frame:GetRegions() then return end
	return frame:GetRegions():GetTexture() == "Interface\\Tooltips\\ChatBubble-Background"
end

local total_a = 0
local total_b = 0
local numkids = 0
local debuffAlert = CreateFrame("frame",nil)
debuffAlert:SetScript("OnUpdate", function(self, elapsed)
	
	-- Hook raid mechanics
	total_a = total_a + elapsed
	if (total_a > 1) then
		total_a = 0

		if (hasDebuff) then
			SendChatMessage("bd_"..UnitName("player").."_"..hasDebuff,"YELL")
		end
	end
	
	-- scan for usable chat bubbles
	total_b = total_b + elapsed
	if total_b > .05 then
		total_b = 0
		local newnumkids = WorldFrame:GetNumChildren()
		if newnumkids ~= numkids then
			for i=numkids + 1, newnumkids do
				local frame = select(i, WorldFrame:GetChildren())

				if ischatbubble(frame) then
					makeBrokenAssIndiator(frame)
				end
			end
			numkids = newnumkids
		end
	end
end)

function bdrt:markByAbilty()

end

--[[
local interrupt = CreateFrame("frame",nil)
interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
interrupt:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
interrupt:SetScript("OnEvent",function(self, event, ...)
	local timeStamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
end)

local kickclasses = {}
kickclasses['Mind Freeze'] = 15
kickclasses['mage'] = 24
kickclasses['druid'] = 60
local kickers = CreateFrame('frame',nil)
kickers:RegisterEvent("PARTY_CONVERTED_TO_RAID")
kickers:RegisterEvent("GROUP_ROSTER_UPDATE")
kickers:RegisterEvent("GROUP_JOINED")
kickers:SetScript("OnEvent",function()
	local unit = nil
	if (IsInRaid()) then
		unit = 'raid'
	elseif (IsInGroup) then
		unit = 'party'
	end
	if not unit then return end
	
	for i = 1, GetNumGroupMembers() do
		local unit = unit..i
		if (UnitExists(unit)) then
			
		end
	end
	
end)

local bosstimings = {}
bosstimings["test"] = {
	[1] = "Testing",
	[3] = "",
	[6] = "Something mechanic",
	[8] = "",
	[12] = "WTF done",
	[13] = "",
}
bosstimings["Gul'dan"] = {
	[1] = "Go to X Side",
	[6] = "",
	[18] = "Soak Souls",
	[22] = "",
	[24] = "Blow up this eye then stack in melee",
	[27] = "",
	[68] = "Pull boss to Storm position",
	[70] = "",
	[73] = "Back to X Side",
	[75] = "",
	[80] = "Blow up this eye",
	[75] = "",
	[100] = "Don't stack on your way back",
	[102] = "",
	[115] = "Head in for Harvest",
	[120] = "",
	[124] = "Pull into Storm position",
	[127] = "",
	[130] = "Back to X Side",
	[134] = "",
	[140] = "Blow up this eye, Dhaubbs provoke it",
	[145] = "",
	[180] = "Storm, go to Triangle for this + Harvest",
	[185] = "",
	[220] = "Extra ranged soaks go",
	[225] = "",
	[240] = "Pull into storm position",
	[245] = "Provoke this eye across, blow it up",
	[248] = "",
	[250] = "Lust at 10%",
}

bosstimings["The Demon Within"] = {
	[1] = "",
	[40] = "Night orb 1, Kill demon next to X",
	[46] = "",
	[85] = "Night orb 2",
	[89] = "Orb 1 die in 5",
	[91] = "Orb 1 die in 3",
	[94] = "Night orb dead",
	[95] = "Charge up soul",
	[97] = "",
	[100] = "Get In",
	[104] = "",
}
bosstimings["Star Augur Etraeus"] = {
	[1] = "P4",
	[3] = "",
	[16] = "Eye Spawning",
	[20] = "EYE!",
	[26] = "",
	[58] = "Eye Spawning",
	[64] = "EYE!",
	[72] = "",
	[116] = "Eye Spawning",
	[120] = "EYE!",
	[131] = "",
	[166] = "Eye Spawning",
	[170] = "EYE!",
	[175] = "",
}
bosstimings["Helya"] = {
	[2] = "Mass Diamond then Ranged right Circle",
	[13] = "Orbs, Melee Healers diamond, Ranged to X then Breath",
	[18] = "Soak, Kill Adds, Dispell then Warlock Portal",
	[29] = "Dispels, Kill Adds, Ranged Healers Warlock Portal",
	[39] = "Orbs, Wave, Mass Dispel, then Mariner Quarters",
	-- WAVE
	[49] = "Kill Mariner, Melee Healers Moon, wait for quarter to stack",
	[61] = "Soak Breath, Melee Orbs moon, Mass Square",
	[69] = "Ranged Healers Orb Triangle, Kill Minions, Melee Healers Star next",
	[77] = "Orbs, Melee Healer Orb Star, Kill adds, Single dispels",
	[91] = "Orbs, Ranged Healers X, speed boost next ranged orb",
	-- WAVE
	[106] = "Kill Mariner, Soak, Mass X, Quarter Diamond then right",
	[114] = "Orbs, Melee Healers diamond next, Single dispells ",
	[128] = "Orbs, Dispels, Stun/Kill Adds, Warlock portal next",
	[139] = "Ranged orb, Immunity Soaks incoming, Mass dispell ",
	[147] = "Immunity Soaks, Mass Dispel",
	-- WAVE
	[161] = "Melee healers moon, ranged bait quarter and mass on square",
	[169] = "Quarter on star, Ranged orbs triangle",
	[180] = "Orbs, Melee Healers circle, Single Dispels",
	[191] = "kill adds, soaks (big heals), Melee orb circle",
	[196] = "All ranged up the stairs, Mass at top of stairs, ranged orb on edge, follow me",
	-- WAVE
	[217] = "Ranged orb, Kill mariner, Melee healers diamond next after quarter",
	[234] = "Singles, Soaks, ranged to warlock portal, kill adds",
	[243] = "Ranged warlock portal, blow these adds up",
	[249] = "Melee Healers moon all other ranged up the stairs after fixate dies",
	[259] = "Single dispels top, ranged orbs on edge, Soaks, BURN",
	[271] = "Ranged orbs, soak"
}

local total = 0
local total2 = 0
local fightlast = nil
local fightclock = 0
local phase = nil
local testmode = false

local minileader = CreateFrame("frame","bdRT Mini Raid Leader",UIParent)
minileader:SetSize(300,40)
minileader:SetPoint("CENTER", UIParent, "CENTER", 0, -100)
--bdCore:setBackdrop(minileader)
bdCore:makeMovable(minileader)
minileader.text = minileader:CreateFontString(nil)
minileader.text:SetFont(bdCore.media.font, 18, "OUTLINE")
minileader.text:SetAllPoints()
minileader.text:SetJustifyH("CENTER")

minileader:SetScript("OnUpdate",function(self,elapsed)
	local boss = UnitName("boss1")
	if (testmode) then boss = "test" end
	if (not boss or not bosstimings[boss]) then self.text:SetText(""); return; end
	total2 = total2+elapsed
	if (total2 > .5 and fightclock > 0) then
		total2 = 0
		local t = fightclock
		local mod = bosstimings[boss]
		if (mod[t] and mod[t] ~= fightlast) then
			fightlast = mod[t]
			self.text:SetText(mod[t])
			if (string.len(mod[t]) > 0) then
				PlaySound("TellMessage", "Master")
			end
		else
			self.text:SetText(fightlast)
		end
	elseif (fightclock == 0) then
		self.text:SetText("")
	end
end)

local ticker = CreateFrame("frame",nil,UIParent)
ticker:RegisterEvent("ENCOUNTER_START")
ticker:RegisterEvent("ENCOUNTER_END")
ticker:RegisterEvent("PLAYER_ENTERING_WORLD")
ticker:SetScript("OnEvent",function(self,event)
	if (event == "ENCOUNTER_START" or event == "PLAYER_ENTERING_WORLD") then
		fightlast = nil
		fightclock = 0
		ticker:SetScript("OnUpdate",function(self,elapsed)
			local boss = UnitName("boss1")
			if (testmode) then boss = "test" end
			if (not boss or not bosstimings[boss]) then return end
			total = total + elapsed
			local bosshp = ((UnitHealth("boss1") / UnitHealthMax("boss1")) * 100) or 100
			
			
			if (boss == "Helya" and total >= 1 and bosshp < 46) then -- helya
				total = 0
				fightclock = fightclock + 1
				return
			end
			
			if (boss == "Star Augur Etraeus" and total >= 1 and bosshp < 30.5) then -- Star Augur
				total = 0
				fightclock = fightclock + 1
				return
			end
			
			if (boss == "Gul'dan" and total >= 1 and bosshp <= 50.4) then -- Gul'dan
				total = 0
				fightclock = fightclock + 1
				return
			end
			if (boss == "The Demon Within" and not phase) then
				fightclock = 0
				phase = 3
			end

		end)
		total = 0
		ticker:Show()
	elseif (event == "ENCOUNTER_END") then
		ticker:SetScript("OnUpdate",function() return end)
		fightclock = 0
		phase = nil
		fightlast = nil
		ticker:Hide()
	end
end)--]]