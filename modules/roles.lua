local bdRaid, vars = unpack(select(2, ...))


local roles = CreateFrame("frame", nil, UIParent)
roles:RegisterEvent("PLAYER_ENTERING_WORLD")
roles:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
roles:SetScript("OnEvent", function(self, event, arg1)

end)

-- getRole
-- return basicRole, specificRole
function bdRaid:GetRole(unit)
	local role = UnitGroupRolesAssigned(unit) -- raid1
	local _, class = UnitClass(unit)
	local spec_role = role

	if (role == "DAMAGER") then
		if (class == "PRIEST" or class == "HUNTER" or class == "MAGE" or class == "WARLOCK" or class == "PRIEST" or class == "SHAMAN" or class == "DRUID") then
			spec_role = "RANGED"
		else
			spec_role = "MELEE"
		end
	end

	return role, spec_role
end