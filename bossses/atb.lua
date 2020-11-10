-- Scripts for all of ATB hopefully

-- garothi
local fight = bdr:NewFight(2076, "Gaorthi Worldbreaker")

-- felhounds
local fight = bdr:NewFight(2074, "Felhound of Sargeras")

-- high command
local fight = bdr:NewFight(2070, "Antoran High Command")
-- fix raid frames to not toggle vehicle

-- portal keeper
local fight = bdr:NewFight(2064, "Portal Keeper Hasabel")

-- eonar
local fight = bdr:NewFight(2075, "Eonar the Life-Binder")

-- imonar
local fight = bdr:NewFight(2082, "Imonar the Soulhunter")
-- assignments for clearing bridge

-- kin'garoth
local fight = bdr:NewFight(2088, "Kin'gorath")
-- assignment soak patterns

-- varimathras
local fight = bdr:NewFight(2069, "Varimathras")

-- coven
local fight = bdr:NewFight(2073, "The Coven of Shivarra")

-- aggrammar
local fight = bdr:NewFight(2063, "Aggramar")

-- argus
local fight = bdr:NewFight(2092, "Argus the Unmaker")
fight:OnStart(function()
	fight.phase = '1';
	fight:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)
fight:OnEnd(function()
	fight.phase = '0';
	fight:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end)