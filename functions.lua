local bdr, c, f = select(2, ...):unpack()

function bdr:sendAction(action, ...)

	local parameters = {...}
	local paramString = ""
	for k, v in pairs(parameters) do
		paramString = paramString.."><"..v
	end
	
	local send = "OFFICER"
	if (not IsInRaid()) then
		send = "WHISPER"
	end

    print("got action", action, paramString)
	
	SendAddonMessage(bdr.prefix, action..paramString, "RAID", UnitName("player"));
end

-- custom events/triggers
bdr.events = {}
function bdr:hookEvent(event, func)
	local events = split(event,",") or {event}
	for i = 1, #events do
		e = events[i]
		if (not bdr.events[e]) then
			bdr.events[e] = {}
		end
		bdr.events[e][#bdr.events[e]+1] = func
	end
end
function bdr:triggerEvent(event,...)
	if (bdr.events[event]) then
		for k, v in pairs(bdr.events[event]) do
			v(...)
		end
	end
end

-- triggering on Boss Messages
bdr.bossMessage = CreateFrame("frame",nil)
bdr.bossMessage:RegisterEvent("CHAT_MSG_MONSTER_YELL")
bdr.bossMessage:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
bdr.bossMessage:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
bdr.bossMessage:RegisterEvent("CHAT_MSG_RAID")
bdr.bossMessage:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
bdr.bossMessage:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
bdr.bossMessage:SetScript("OnEvent", function(self, message, sender, language, channel, target)
	bdr:triggerEvent("bdr_bossMessage", message, sender, target)
end)
-- smart hook
function bdr:onBossMessage(contains, func)
	bdr:hookEvent("bdr_bossMessage", function(message, sender, target)
		if strfind(message, contains) then
			func(message, sender, target)
		end
	end)
end

function bdr:addIconToFrame(parentFrame, spellID, duration)
	local frame = parentFrame.additionalIcon or CreateFrame("frame",nil,parentFrame)
	frame:SetFrameStrata("HIGH")
	frame:SetWidth(aura_env.iconWidth)
	frame:SetHeight(aura_env.iconHeight)
	frame:SetAlpha(aura_env.iconAlpha)

	local texture = frame.texture or frame:CreateTexture(nil,"HIGH")
	texture:SetTexture(select(3, GetSpellInfo(spellID)))
	texture:SetAllPoints(frame)
	frame.texture = texture

	frame:SetPoint(aura_env.position,0,0)

	local cooldown = frame.cooldown or CreateFrame("COOLDOWN", nil, frame, "CooldownFrameTemplate")
	cooldown:SetCooldown(GetTime(), duration)
	cooldown:SetAllPoints(frame)
	cooldown:SetDrawEdge(false)
	cooldown:SetHideCountdownNumbers(IsAddOnLoaded("OmniCC") or false)
	frame.cooldown = cooldown

	frame:Show()
	C_Timer.After(duration, function() frame:Hide() end)
end

bdr.soloableClasses = {}
bdr.soloableAbilities = {}
function bdr:resetVars()  
    bdr.soloableClasses = {}   
    soloableClasses["Paladin"] = true
    soloableClasses["Mage"] = true
    soloableClasses["Hunter"] = true
    soloableClasses["Rogue"] = true

    bdr.soloableAbilities = {}
    bdr.soloableAbilities["Aspect of the Turtle"] = true
    bdr.soloableAbilities["Ice Block"] = true
    bdr.soloableAbilities["Divine Shield"] = true
    bdr.soloableAbilities["Cloak of Shadows"] = true
end

function bdr:iCanSolo()
    -- we check for < 3 seconds because most mechanics have a longer duration
    local class = UnitClass("player")

    local hasCD = false
    local cds = bdr.soloableAbilities

    for k, v in pairs(cds) do
        if (GetSpellCooldown(k)) and select(1, GetSpellCooldown(k)) < 3) then
            hasCd = true
        end
    end

    return hasCD
end

function bdr:modifyRaidFrame(callback)
	local hasVuhDo = IsAddOnLoaded("VuhDo")
	local hasbdGrid = IsAddOnLoaded("bdGrid")
	local hasGrid2 = IsAddOnLoaded("Grid2")
    local hasElvUI = _G["ElvUF_Raid"] and _G["ElvUF_Raid"]:IsVisible()
    
    if hasElvUI then
        for i=1, 8 do
            for j=1, 5 do
                local f = _G["ElvUF_RaidGroup"..i.."UnitButton"..j]
                if f and f.unit then
                    callback(f)
                end
            end
        end
    elseif hasVuhDo then
        
    elseif hasbdGrid then
		for i=1, 40 do
            local f = _G["oUF_bdGridUnitButton"..i]
            if f and f.unit then
                callback(f)
            end
        end
    elseif hasGrid2 then
        local layout = Grid2LayoutFrame
        
        if layout then
            local children = {layout:GetChildren()}
            for _, child in ipairs(children) do
                if child:IsVisible() then
                    local frames = {child:GetChildren()}
                    for _, f in ipairs(frames) do
                        if f.unit then
                            callback(f)
                        end
                    end
                end
            end
        end
    else
        for i=1, 40 do
            local f = _G["CompactRaidFrame"..i]
            if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                aura_env.addIcon(f)
                return
            end
        end
        for i=1, 4 do
            for j=1, 5 do
                local f = _G["CompactRaidGroup"..i.."Member"..j]
                if f and f.unitExists and f.unit and UnitName(f.unit) == target then
                    aura_env.addIcon(f)
                    return
                end
            end
        end
    end
end