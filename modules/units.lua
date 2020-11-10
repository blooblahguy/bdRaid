local bdRaid, c, l = unpack(select(2, ...))

function bdRaid:UnitInRadius(unit, yards)
	if (UnitIsUnit("player", unit)) then
		return true
	end
	if (UnitIsDeadOrGhost(unit)) then
		return false
	end

	local range = 1000
	if IsItemInRange(37727, unit) then range = 5 --Ruby Acorn
	elseif IsItemInRange(63427, unit) then range = 8 --Worgsaw
	elseif CheckInteractDistance(unit, 3) then range = 10
	elseif CheckInteractDistance(unit, 2) then range = 11
	elseif IsItemInRange(32321, unit) then range = 13 --reports 12 but actual range tested is 13
	elseif IsItemInRange(6450, unit) then range = 18 --Bandages
	elseif IsItemInRange(21519, unit) then range = 22 --Item says 20, returns true until 22.
	elseif CheckInteractDistance(unit, 1) then range = 30
	elseif UnitInRange(unit) then range = 43
	elseif IsItemInRange(116139, unit)  then range = 50
	elseif IsItemInRange(32825, unit) then range = 60
	elseif IsItemInRange(35278, unit) then range = 80 end

	if (range <= yards) then
		return true
	end

	return false
end