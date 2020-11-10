--[[
local bossmodules = CreateFrame("frame",nil)
bossmodules:RegisterEvent("ENCOUNTER_START")

bossmodules:SetScript("OnEvent",function()
	
end)--]]
--[[
local modules = {}
modules["Guarm"] = {}
modules["Guarm"]["Flaming Volatile Foam"] = {0,6,0.5,0,0,1}
modules["Guarm"]["Briney Volatile Foam"] = {0,6,0,0,0.5,1}
modules["Guarm"]["Shadowy Volatile Foam"] = {0,6,0.7,0.4,0.9,1}

modules["Helya"] = {}
modules["Helya"]["Fetid Rot"] = {0,5,0.1,0.5,0,1}

modules['Spellblade Aluriel'] = {}
modules['Spellblade Aluriel']["Mark of Frost"] = {0,3,0,0,0.5,1}
modules['Spellblade Aluriel']["Searing Brand"] = {24,8,0.5,0,0,1}

modules["Solarist Tel'arn"] = {}
modules["Solarist Tel'arn"]["Parasitic Fetter"] = {0,6,0,0.5,0,1}

modules["Tichondrius"] = {}
modules["Tichondrius"]["Burning Soul"] = {0,8,0,0,0.5,1}--]]

--[[
local moduledriver = CreateFrame('frame',nil)
moduledriver:RegisterEvent("UNIT_AURA")
moduledriver:RegisterEvent("NAME_PLATE_UNIT_ADDED")
moduledriver:SetScript("OnEvent",function()
	if (not UnitExists("boss1")) then return end
	local mod = modules[UnitName("boss1")]
	if not mod then return end
	local show = false
	local cyards = 0
	local colors = {}
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local unit = frame.unitFrame.unit
		local ouf = frame.ouf
		for spell, data in pairs(mod) do
			local debuff = select(1, UnitDebuff(unit,spell))
			local duration, yards, r, g, b, a = unpack(data)
			ouf.Circle:Hide()
			if (debuff) then
				local expiration = select(7, UnitDebuff(unit, spell)) - GetTime()
				show = true
				cyards = yards
				colors = {r,g,b,a}
				if (expiration < duration) then
					show = false
				end
			end
		end
	end
	
	if (show) then
		ouf.Circle:Show()
		ouf.Circle:SetYards(cyards)
		ouf.Circle:SetColor(unpack(colors))
	else
		ouf.Circle:Hide()
	end
end)--]]
--[[
local test = CreateFrame("frame")
test:RegisterEvent("UNIT_AURA")
test:RegisterEvent("")
test:SetScript("OnEvent",function()
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		local unit = frame.unitFrame.unit
		local ouf = frame.ouf
		ouf.Circle:Hide()
		
		local freedom = select(1, UnitBuff(unit,"Blessing of Freedom"))
		
		if (freedom) then
			local expiration = select(7, UnitBuff(unit,"Blessing of Freedom")) - GetTime()

			if (expiration > 2) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(3)
				ouf.Circle:SetColor(0,0,0.5,1)
			end
		end
	end
end)--]]
--[[
local spellblade = CreateFrame("frame")
spellblade:RegisterEvent("UNIT_AURA")
spellblade:RegisterEvent("NAME_PLATE_UNIT_ADDED")
spellblade:SetScript("OnEvent",function()
	if (not UnitExists("boss1")) then return end 
	if (not UnitName("boss1") == "Spellblade Aluriel") then return end 
	
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if (not frame.unitFrame) then return end
		local unit = frame.unitFrame.unit
		local ouf = frame.ouf
		local frost = select(1, UnitDebuff(unit,"Mark of Frost"))
		local flame = select(1, UnitDebuff(unit,"Searing Brand"))
		local tank = UnitIsUnit("boss1target",unit)
		ouf.Circle:Hide()
		
	
		if (frost) then
			ouf.Circle:Show()
			ouf.Circle:SetYards(3)
			ouf.Circle:SetColor(0,0,0.5,1)
		end
		
		if (flame) then
			local expiration = select(7, UnitDebuff(unit, "Searing Brand")) - GetTime()
			if (expiration > 24) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(3)
				ouf.Circle:SetColor(0,0,0,1)
			end
		end
		
		if (parasite) then
			ouf.Circle:Show()
			ouf.Circle:SetYards(3)
			ouf.Circle:SetColor(.7,.4,.9,1)
		end
	end
end)
--]]
--[[
local guldan = CreateFrame("frame")
guldan:RegisterEvent("UNIT_AURA")
guldan:RegisterEvent("NAME_PLATE_UNIT_ADDED")
guldan:RegisterEvent("PLAYER_TARGET_CHANGED")
guldan:SetScript("OnEvent",function(self,event)
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if (not frame.unitFrame) then return end
		local unit = frame.unitFrame.unit
		local ouf = frame.ouf
		ouf.Circle:Hide()
		ouf.Circle:SetType(1)
		ouf.Namecontainer:SetAlpha(config.friendnamealpha)
		if (not config.bossmodules) then return end
		if (UnitExists("boss1") and UnitName("boss1") == "Gul'dan") then
			local eye = select(1, UnitDebuff(unit,"Eye of Gul'dan"))
			local eye2 = select(1, UnitDebuff(unit,"Empowered Eye of Gul'dan"))
			local bonds = select(1, UnitDebuff(unit,"Bonds of Fel"))
			local bonds2 = select(1, UnitDebuff(unit,"Empowered Bonds of Fel"))
			local flames = select(1, UnitDebuff(unit,"Flames of Sargeras"))
			local tank = UnitIsUnit("boss1target",unit)
			
			if ((eye or eye2) and UnitIsPlayer(unit)) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(8)
				ouf.Circle:SetColor(.5,0,0,1,0.5)
				ouf.Circle:SetType(2)
				ouf.Namecontainer:SetAlpha(1)
			end
			
			if (flames) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(8)
				ouf.Circle:SetColor(.8,0,0,1,0.5)
				ouf.Circle:SetType(2)
				ouf.Namecontainer:SetAlpha(1)
			end
			
			if (bonds or bonds2) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(5)
				ouf.Circle:SetColor(.5,0.5,0,0.8,1)
				ouf.Namecontainer:SetAlpha(1)
			end
			
			if (tank) then
				ouf.Circle:Show()
				ouf.Circle:SetYards(3)
				ouf.Circle:SetColor(0,0,0,1)
				ouf.Namecontainer:SetAlpha(1)
			end
		end
	end
end)--]]
--[[
local augur = CreateFrame("frame")
augur:RegisterEvent("UNIT_AURA")
augur:RegisterEvent("NAME_PLATE_UNIT_ADDED")
augur:SetScript("OnEvent",function()
	if (not config.bossmodules) then return end
	if (not UnitExists("boss1")) then return end 
	if (not UnitName("boss1") == "Star Augur Etraeus") then return end 

	local playermark = select(1, UnitDebuff("player","Star Sign: Crab")) or nil
	playermark = playermark or select(1, UnitDebuff("player","Star Sign: Wolf")) or nil
	playermark = playermark or select(1, UnitDebuff("player","Star Sign: Dragon")) or nil
	playermark = playermark or select(1, UnitDebuff("player","Star Sign: Hunter")) or nil
	
	for _, frame in pairs(C_NamePlate.GetNamePlates()) do
		if (not frame.unitFrame) then return end
		local unit = frame.unitFrame.unit
		if (not UnitExists(unit)) then return end
		local ouf = frame.ouf
		
		if (not frame.MarkAlert) then
			frame.MarkAlert = CreateFrame("Cooldown",nil,frame,"CooldownFrameTemplate")
			frame.MarkAlert:SetFrameStrata("TOOLTIP")
			frame.MarkAlert:SetFrameLevel(10)
			frame.MarkAlert:SetSize(50,50)
			frame.MarkAlert:SetReverse(true)
			frame.MarkAlert:SetHideCountdownNumbers(true)
			frame.MarkAlert:SetBlingTexture('')
			bdCore:setBackdrop(frame.MarkAlert)
			
			frame.MarkAlert.tex = frame.MarkAlert:CreateTexture(nil,"BORDER")
			frame.MarkAlert.tex:SetAllPoints(frame.MarkAlert)
			frame.MarkAlert.tex:SetTexCoord(0.08, 0.9, 0.08, 0.9)
			
			frame.MarkAlert.text = frame.MarkAlert:CreateFontString(nil,"OVERLAY")
			frame.MarkAlert.text:SetFont(bdCore.media.font,20,"OUTLINE")
			frame.MarkAlert.text:SetJustifyH("CENTER")
			frame.MarkAlert.text:SetText("1")
			frame.MarkAlert.text:SetPoint("CENTER")

		end
		
		frame.MarkAlert:ClearAllPoints()
		if (UnitIsUnit("player",unit)) then
			frame.MarkAlert:SetPoint("BOTTOM", ouf.Name, "TOP", -2, 10)
		else
			frame.MarkAlert:SetPoint("BOTTOM", ouf, "TOP", -2, 18)
		end
		
		local platemark = select(1, UnitDebuff(unit,"Star Sign: Crab")) or nil
		platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Wolf")) or nil
		platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Dragon")) or nil
		platemark = platemark or select(1, UnitDebuff(unit,"Star Sign: Hunter")) or nil
	
		if (platemark == "Star Sign: Crab") then
			frame.MarkAlert.text:SetText("1")
		elseif (platemark == "Star Sign: Wolf") then
			frame.MarkAlert.text:SetText("2")
		elseif (platemark == "Star Sign: Dragon") then
			frame.MarkAlert.text:SetText("3")
		elseif (platemark == "Star Sign: Hunter") then
			frame.MarkAlert.text:SetText("4")
		end
		
		if (platemark and playermark and platemark == playermark) then -- make green
			local duration = select(6, UnitDebuff(unit, platemark))
			local expiration = select(7, UnitDebuff(unit, platemark))
			frame.MarkAlert.tex:SetTexture(236595)
			frame.MarkAlert:SetFrameLevel(10)
			frame.MarkAlert:Show()
			frame.MarkAlert:SetAlpha(1)
			frame.MarkAlert:SetCooldown(expiration - duration, duration)
		elseif (platemark) then -- make red
			local duration = select(6, UnitDebuff(unit, platemark))
			local expiration = select(7, UnitDebuff(unit, platemark))
			local icon = select(3, UnitDebuff(unit, platemark))
			frame.MarkAlert.tex:SetTexture(236612)
			frame.MarkAlert:SetFrameLevel(12)
			frame.MarkAlert:Show()
			frame.MarkAlert:SetAlpha(1)
			frame.MarkAlert:SetCooldown(expiration - duration, duration)
			if (not playermark and icon) then 
				frame.MarkAlert.tex:SetTexture(icon) 
				frame.MarkAlert:SetAlpha(0.5)
			end
		else
			frame.MarkAlert:Hide()
		end

	end
end)--]]