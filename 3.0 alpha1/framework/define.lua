--===================================================
-- File Name    : define.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:59
-- Description  :
-- Modify       :
--===================================================

if not Def then
	Def = {}
end

Def.menu_font_name = "MarkerFelt-Thin"
if device == "win32" then
	Def.menu_font_name = "Microsoft Yahei"
end

Def.ZOOM_LEVEL_WORLD = 1
Def.ZOOM_LEVEL_BULLET = 2
Def.ZOOM_LEVEL_TITLE = 3
Def.ZOOM_LEVEL_PERFORMANCE = 4
Def.ZOOM_LEVEL_MENU = 5
Def.ZOOM_LEVEL_SUB_MENU = 6

Def.ZOOM_LEVEL_SYSMSG = 1000

Def.color_list = {
	["black"] = cc.c3b(0, 0, 0),
	["red"]   = cc.c3b(255, 0, 0),
	["green"] = cc.c3b(0, 255, 0),
	["blue"]  = cc.c3b(0, 0, 255),
	["white"] = cc.c3b(255, 255, 255),
	["yellow"] = cc.c3b(255, 255, 0),
}

function Def:GetColor(color_name)
	return self.color_list[color_name]
end


