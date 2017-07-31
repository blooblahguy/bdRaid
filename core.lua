local addon, engine = ...

engine[1] = CreateFrame("Frame", nil, UIParent)
engine[2] = {}
engine[3] = {}

engine[1]:RegisterEvent("ADDON_LOADED")

function engine:unpack()
	return self[1], self[2], self[3]
end


bdr = engine[1]
bdr.colorString = '|cffA02C2Fbd|r'
bdr.config = engine[2]
bdr.frames = engine[3]
bdr.addonPath = "Interface\\Addons\\bdCore\\"

bdr.font = CreateFont("bdCore.font")
bdr.font:SetFont(bdr.addonPath.."media\\roboto.ttf", 13)
bdr.font:SetShadowColor(0, 0, 0)
bdr.font:SetShadowOffset(1, -1)

bdr.prefix = "bdRaid"

RegisterAddonMessagePrefix(bdr.prefix)