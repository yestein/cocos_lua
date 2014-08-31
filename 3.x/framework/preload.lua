--===================================================
-- File Name    : preload.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:07:04
-- Description  :
-- Modify       :
--===================================================

local g_script_list = {}
local g_init_funciton = {}

function AddPreloadFile(script_file)
	g_script_list[#g_script_list + 1] = script_file
end

function AddProjectScript(script_file)
	return AddPreloadFile(PROJECT_PATH.."/"..script_file)
end


function AddInitFunction(name, func)
	g_init_funciton[name] = func
end

function PreloadScript()
	for _, script_file in ipairs(g_script_list) do
		print("loading \""..script_file.."\"")
		require(script_file)
	end
	for name, func in pairs(g_init_funciton) do
		local result, ret_code = Lib:SafeCall({func})
		if not result or ret_code ~= 1 then
			assert(false, "%s execute failed", name)
			return 0
		end
	end
	return 1
end

function ReloadScript()
	if __platform == cc.PLATFORM_OS_WINDOWS then
		print("Reload Lua Script...")
		for _, script_file in ipairs(g_script_list) do
			dofile("src/"..script_file)
			print("Reload\t["..script_file.."]")
		end

		for name, func in pairs(g_init_funciton) do
			print(name .. "...")
			Lib:SafeCall({func})
		end
	else
		print("Can not support Script Reload!!")
	end
end

AddPreloadFile("framework/log.lua")
AddPreloadFile("framework/lib.lua")
AddPreloadFile("framework/class.lua")
AddPreloadFile("framework/event.lua")
AddPreloadFile("framework/dbg.lua")

AddPreloadFile("framework/physics_mgr.lua")
AddPreloadFile("framework/define.lua")
AddPreloadFile("framework/timer_base.lua")

AddPreloadFile("framework/logic/logic_node.lua")
AddPreloadFile("framework/logic/game_mgr.lua")
AddPreloadFile("framework/logic/module_mgr.lua")
AddPreloadFile("framework/logic/obj_base.lua")
AddPreloadFile("framework/logic/obj_pool.lua")
AddPreloadFile("framework/logic/real_timer.lua")
AddPreloadFile("framework/logic/logic_timer.lua")
AddPreloadFile("framework/logic/slide_helper.lua")
AddPreloadFile("framework/logic/component_mgr.lua")
AddPreloadFile("framework/logic/pick_helper.lua")
AddPreloadFile("framework/logic/movie.lua")
AddPreloadFile("framework/logic/wait_helper.lua")

AddPreloadFile("framework/logic/ai/ai_mgr.lua")
AddPreloadFile("framework/logic/buff/buff_base.lua")
AddPreloadFile("framework/logic/buff/buff_mgr.lua")
AddPreloadFile("framework/logic/skill/skill_mgr.lua")
AddPreloadFile("framework/logic/skill/skill_template.lua")
AddPreloadFile("framework/logic/skill/skill_cast.lua")
AddPreloadFile("framework/logic/skill/skill_effect.lua")

AddPreloadFile("framework/logic/editor/gm.lua")
AddPreloadFile("framework/logic/rpg/obj.lua")

AddPreloadFile("framework/logic/component/move_node.lua")
AddPreloadFile("framework/logic/component/bullet_node.lua")
AddPreloadFile("framework/logic/component/cmd_node.lua")
AddPreloadFile("framework/logic/component/ai_node.lua")
AddPreloadFile("framework/logic/component/log_node.lua")
AddPreloadFile("framework/logic/component/buff_node.lua")
AddPreloadFile("framework/logic/component/cd_node.lua")
AddPreloadFile("framework/logic/component/skill_node.lua")
AddPreloadFile("framework/logic/component/action_node.lua")
AddPreloadFile("framework/logic/component/movie_node.lua")

AddPreloadFile("framework/cocos2d/resource_mgr.lua")
AddPreloadFile("framework/cocos2d/ui.lua")
AddPreloadFile("framework/cocos2d/menu.lua")
AddPreloadFile("framework/cocos2d/sprite_sheets.lua")
AddPreloadFile("framework/cocos2d/particles.lua")
AddPreloadFile("framework/cocos2d/progress_bar.lua")
AddPreloadFile("framework/cocos2d/scene_base.lua")
AddPreloadFile("framework/cocos2d/scene_base_ex.lua")
AddPreloadFile("framework/cocos2d/scene_mgr.lua")
AddPreloadFile("framework/cocos2d/skelton.lua")
AddPreloadFile("framework/cocos2d/skelton_ex.lua")
AddPreloadFile("framework/cocos2d/skelton_pool.lua")


AddPreloadFile("framework/effects/fly_text.lua")
AddPreloadFile("framework/effects/effect_mgr.lua")
AddPreloadFile(PROJECT_PATH.."/game_mgr.lua")