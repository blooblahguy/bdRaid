local addon, engine = ...

engine[1] = CreateFrame("Frame", nil, UIParent)
engine[2] = {}

local bdRaid = engine[1]

bdRaid.colorString = '|cffA02C2Fbd|r'
bdRaid.config = engine[2]
bdRaid.frames = engine[3]
bdRaid.addonPath = "Interface\\Addons\\bdRaid\\"

bdRaid.font = CreateFont("bdCore.font")
bdRaid.font:SetFont(bdr.addonPath.."media\\roboto.ttf", 13)
bdRaid.font:SetShadowColor(0, 0, 0)
bdRaid.font:SetShadowOffset(1, -1)

C_ChatInfo.RegisterAddonMessagePrefix(bdr.prefix)
