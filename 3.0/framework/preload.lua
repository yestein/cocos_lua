--===================================================
-- File Name    : preload.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:07:04
-- Description  :
-- Modify       :
--===================================================

local g_script_list = {}

function AddPreloadFile(script_file)
	g_script_list[#g_script_list + 1] = script_file
end

function AddProjectScript(script_file)
	return AddPreloadFile(PROJECT_PATH.."/"..script_file)
end

function PreloadScript()
	for _, script_file in ipairs(g_script_list) do
		require(script_file)
	end
end

function ReloadScript()
	if device == "win32" then
		print("Reload Lua Script...")
		for _, script_file in ipairs(g_script_list) do
			dofile(script_file)
			print("Reload\t["..script_file.."]")
		end
	else
		print("Can not support Script Reload!!")
	end
end

AddPreloadFile("framework/lib.lua")
AddPreloadFile("framework/event.lua")
AddPreloadFile("framework/dbg.lua")

AddPreloadFile("framework/physics_mgr.lua")
AddPreloadFile("framework/define.lua")

AddPreloadFile("framework/logic/game_mgr.lua")
AddPreloadFile("framework/logic/logic_node.lua")
AddPreloadFile("framework/logic/module_base.lua")
AddPreloadFile("framework/logic/obj_base.lua")
AddPreloadFile("framework/logic/obj_pool.lua")
AddPreloadFile("framework/logic/editor/gm.lua")


AddPreloadFile("framework/cocos2d/ui.lua")
AddPreloadFile("framework/cocos2d/menu.lua")
AddPreloadFile("framework/cocos2d/scene_base.lua")
AddPreloadFile("framework/cocos2d/scene_mgr.lua")

AddPreloadFile("framework/effects/fly_text.lua")
AddPreloadFile(PROJECT_PATH.."/game_mgr.lua")