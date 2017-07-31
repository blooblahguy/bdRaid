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
	
	SendAddonMessage(bdlc.message_prefix, action.."><"..paramString, bdlc.sendTo, UnitName("player"));
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