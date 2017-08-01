local bdr, c, f = select(2, ...):unpack()

local fight = bdr:NewFight(2052, "Maiden of Vigilance")

fight.display = CreateFrame("frame",'bdRaid Maiden Assignment',UIParent)
local display = fight.display
display:SetSize(400, 40)
display:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
display:SetMovable(true)
display:EnableMouse(true)
display:RegisterForDrag("LeftButton")
display:SetScript("OnDragStart", function() 
	if (IsShiftKeyDown()) then 
		display:StartMoving()
	end
end)
display:SetScript("OnDragStop", display.StopMovingOrSizing)

display.text = display:CreateFontString(nil)
dispaly.text:SetFont(bdr.font, 16, "OUTLINE")
dispaly.text:SetAllPoints(display)
dispaly.text:SetJustifyH("CENTER")
dispaly.text:SetJustifyY("CENTER")
display.SetText = display.text.SetText

display:SetText("|cffE5EC00Holy|r or |cff3AD10DFel|r: Left Back #1-5")
display:Hide()

fight:OnStart(function()
	fight.phase = '1';
	fight:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	fight:SetScript("OnEvent",function(self,event,...)
		if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
			timeStamp, subevent, hideCaster, sourceGUID, sourceName, 
			sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags,
			spellID, spellName, spellSchool, amount = ...
			
			if (subevent == "SPELL_AURA_APPLIED" and UnitIsUnit("player", destName) and (spellName == "Holy Infusion" or spellName == "Light Infusion")) then
				C_Timer.After(1, fight.AssignMarks)
			end
		end
	end)
end)

fight:OnEnd(function()
	fight.phase = '0';
	fight:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	fight.display:Hide()
end)

function fight:AssignMarks()
	local tanks = bdr.roles.tanks
	local healers = bdr.roles.healers
	local melee = bdr.roles.melee
	local ranged = bdr.roles.ranged
	
	local assigns = {}
    assigns.left = {}
    assigns.left.fel = {} -- front left
    assigns.left.holy = {} -- back left
    
    assigns.right = {} 
    assigns.right.holy = {} -- front right
    assigns.right.fel = {} -- back right
    
    local assigned = {}
	
	-- assigns tanks to front interceptor positions (3)
    for name, v in pairs(tanks) do
        if (UnitExists(name) and not UnitIsDead(name)) then
            local text = ""
            local fel = select(1, UnitDebuff(name,"Fel Infusion"))
            local holy = select(1, UnitDebuff(name,"Light Infusion"))
            
            if (fel) then
                text = "|cff3AD10DFel|r Melee #5"
                assigns.left.fel[5] = name
                assigns.left.fel[name] = text
            elseif (holy) then
                text = "|cffE5EC00Holy|r Melee #5"
                assigns.right.holy[5] = name
                assigns.right.holy[name] = text
            end
            
            assigned[name] = text
        end
    end
	
	-- assign melee to movement positions (2, 4, 1, 5)
    for raider = 1, 30 do --for name, v in pairs(melee) do
        local name = UnitName("raid"..raider)
        if (name and melee[name] and UnitExists(name) and not UnitIsDead(name)) then
            local text = ""
            local fel = select(1, UnitDebuff(name,"Fel Infusion"))
            local holy = select(1, UnitDebuff(name,"Light Infusion"))
            local locations = {[1]=1,[2]=3,[3]=5}
            
            if (fel) then
                for key, row in pairs(locations) do
                    if (not assigns.left.fel[row] and not assigned[name]) then
                        text = "|cff3AD10DFel|r Melee #"..row
                        assigns.left.fel[row] = name
                        assigns.left.fel[name] = text
                        assigned[name] = text
                    end
                end
                -- if there isn't a spot, double up in the stationary spot.
                if (not assigns.left.fel[name]) then
                    assigns.left.fel[2] = name
                    assigns.left.fel[name] = "|cff3AD10DFel|r Melee #2"
                    assigned[name] = "|cff3AD10DFel|r Melee #2"
                end
            elseif (holy) then
                for key, row in pairs(locations) do
                    if (not assigns.right.holy[row] and not assigned[name]) then
                        text = "|cffE5EC00Holy|r Melee #"..row
                        assigns.right.holy[row] = name
                        assigns.right.holy[name] = text
                        assigned[name] = text
                    end
                end
                -- if there isn't a spot, double up in the stationary spot.
                if (not assigns.right.holy[name]) then
                    assigns.right.holy[2] = name
                    assigns.right.holy[name] = "|cffE5EC00Holy|r Melee #2"
                    assigned[name] = "|cffE5EC00Holy|r Melee #2"
                end
            end
        end
    end
	
	-- assign ranged/extras to back rows prioritizing stationary positions for ranged nearest to the front of the raid.
    for raider = 1, 30 do --for name, v in pairs(ranged) do
        local name = UnitName("raid"..raider)
        if (name and ranged[name] and UnitExists(name) and not UnitIsDead(name)) then
            local text = ""
            local fel = select(1, UnitDebuff(name,"Fel Infusion"))
            local holy = select(1, UnitDebuff(name,"Light Infusion"))
            local locations = {[1]=1,[2]=3,[3]=5} 
            
            if (fel) then
                for key, row in pairs(locations) do
                    if (not assigns.right.fel[row] and not assigned[name]) then
                        text = "|cff3AD10DFel|r Ranged #"..row
                        assigns.right.fel[row] = name
                        assigns.right.fel[name] = text
                        assigned[name] = text
                    end
                end
                -- if there isn't a spot, double up in the stationary spot.
                if (not assigns.right.fel[name]) then
                    assigns.right.fel[2] = name
                    assigns.right.fel[name] = "|cff3AD10DFel|r Ranged #2"
                    assigned[name] = "|cff3AD10DFel|r Ranged #2"
                end
            elseif (holy) then
                for key, row in pairs(locations) do
                    if (not assigns.left.holy[row] and not assigned[name]) then
                        text = "|cffE5EC00Holy|r Ranged #"..row
                        assigns.left.holy[row] = name
                        assigns.left.holy[name] = text
                        assigned[name] = text
                        
                    end
                end
                -- if there isn't a spot, double up in the melee stationary spot.
                if (not assigns.left.holy[name]) then
                    assigns.left.holy[2] = name
                    assigns.left.holy[name] = "|cffE5EC00Holy|r Ranged #2"
                    assigned[name] = "|cffE5EC00Holy|r Ranged #2"
                end
            end
        end
    end
	
	-- fill healers into remaining positions
	for raider = 1, 30 do
        local name = UnitName("raid"..raider)
        if (name and healers[name] and UnitExists(name) and not UnitIsDead(name)) then
            local text = ""
            local fel = select(1, UnitDebuff(name,"Fel Infusion"))
            local holy = select(1, UnitDebuff(name,"Light Infusion"))
            local locations = {[1]=1,[2]=3,[3]=5}
            
            if (fel) then
                for key, row in pairs(locations) do
                    if (not assigns.right.fel[row] and not assigned[name]) then
                        text = "|cff3AD10DFel|r Ranged #"..row
                        assigns.right.fel[row] = name
                        assigns.right.fel[name] = text
                        assigned[name] = text
                    end
                end
                for key, row in pairs(locations) do
                    if (not assigns.left.fel[row] and not assigned[name]) then
                        text = "|cff3AD10DFel|r Melee #"..row
                        assigns.left.fel[row] = name
                        assigns.left.fel[name] = text
                        assigned[name] = text
                    end
                end
                -- if there isn't a spot, double up in the stationary spot.
                if (not assigned[name]) then
                    assigns.left.fel[2] = name
                    assigns.left.fel[name] = "|cff3AD10DFel|r Melee #2"
                    assigned[name] = "|cff3AD10DFel|r Melee #2"
                end
            elseif (holy) then
                for key, row in pairs(locations) do
                    if (not assigns.left.holy[row] and not assigned[name]) then
                        text = "|cffE5EC00Holy|r Ranged #"..row
                        assigns.left.holy[row] = name
                        assigns.left.holy[name] = text
                        assigned[name] = text
                    end
                end
                for key, row in pairs(locations) do
                    if (not assigns.right.holy[row] and not assigned[name]) then
                        text = "|cffE5EC00Holy|r Melee #"..row
                        assigns.right.holy[row] = name
                        assigns.right.holy[name] = text
                        assigned[name] = text
                    end
                end
                -- if there isn't a spot, double up in the melee stationary spot.
                if (not assigned[name]) then
                    assigns.right.holy[2] = name
                    assigns.right.holy[name] = "|cffE5EC00Holy|r Melee #2"
                    assigned[name] = "|cffE5EC00Holy|r Melee #2"
                end
            end
        end
    end
	
	-- debug info
	if (UnitIsGroupLeader('player')) then
        SendChatMessage("Operate WA", "RAID")
		
        local text = {};
        for pos, name in pairs(assigns.left.fel) do
            text[pos] = text[pos] or ""
            text[pos] = text[pos]..name..", "
        end
        for i = 1, 5, 2 do 
            if (text[i]) then
                print("|cff3AD10DFel|r Melee #"..i..": "..text[i]); 
            end
        end
        
        local text = {};
        for pos, name in pairs(assigns.left.holy) do
            text[pos] = text[pos] or ""
            text[pos] = text[pos]..name..", "
        end
        for i = 1, 5, 2 do 
            if (text[i]) then
                print("|cffE5EC00Holy|r Ranged #"..i..": "..text[i]); 
            end
        end
        
        local text = {};
        for pos, name in pairs(assigns.right.holy) do
            text[pos] = text[pos] or ""
            text[pos] = text[pos]..name..", "
        end
        for i = 1, 5, 2 do 
            if (text[i]) then
                print("|cffE5EC00Holy|r Melee #"..i..": "..text[i]); 
            end
        end
        
        local text = {};
        for pos, name in pairs(assigns.right.fel) do
            text[pos] = text[pos] or ""
            text[pos] = text[pos]..name..", "
        end
        for i = 1, 5, 2 do 
            if (text[i]) then
                print("|cff3AD10DFel|r Ranged #"..i..": "..text[i]); 
            end
        end
    end
	
	fight.display:SetText(assigned[name])
	fight.display:Show()
end


