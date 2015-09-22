--===================================================
-- File Name    : preload.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:07:04
-- Description  :
-- Modify       :
--===================================================

local g_script_list = {}
local g_init_funciton = {}
local g_addition_package_path = {}
local raw_package_path = package.path

if _VERSION == "Lua 5.3" then
    pack = table.pack
    unpack = table.unpack
end

function AddPackagePath(package_path)
    g_addition_package_path[package_path] = 1
end

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
    print("old path", raw_package_path)
    local new_package_path = ""
    for path, _ in pairs(g_addition_package_path) do
        print(path)
        new_package_path = string.format("src/%s/?.lua;", path) .. new_package_path
    end
    package.path = new_package_path .. raw_package_path
    print("Package Path", package.path)
    for _, script_file in ipairs(g_script_list) do
        print("loading \""..script_file.."\"")
        require("src/".. script_file..".lua")
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
            dofile("src/"..script_file .. ".lua")
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

AddPreloadFile("framework/log")
AddPreloadFile("framework/lib")
AddPreloadFile("framework/class")
AddPreloadFile("framework/event")
AddPreloadFile("framework/dbg")
AddPreloadFile("framework/stat")

AddPreloadFile("framework/physics_mgr")
AddPreloadFile("framework/define")
AddPreloadFile("framework/timer_base")
AddPreloadFile("framework/shader_mgr")
AddPreloadFile("framework/random_pool")

AddPreloadFile("framework/logic/logic_node")
AddPreloadFile("framework/logic/game_mgr")
AddPreloadFile("framework/logic/module_mgr")
AddPreloadFile("framework/logic/story_mgr")
AddPreloadFile("framework/logic/obj_base")
AddPreloadFile("framework/logic/obj_pool")
AddPreloadFile("framework/logic/real_timer")
AddPreloadFile("framework/logic/logic_timer")
AddPreloadFile("framework/logic/slide_helper")
AddPreloadFile("framework/logic/component_mgr")
AddPreloadFile("framework/logic/pick_helper")
AddPreloadFile("framework/logic/movie")
AddPreloadFile("framework/logic/wait_helper")
AddPreloadFile("framework/logic/data_center")
AddPreloadFile("framework/logic/slide_count_helper")

AddPreloadFile("framework/logic/ai/ai_mgr")
AddPreloadFile("framework/logic/buff/buff_base")
AddPreloadFile("framework/logic/buff/buff_mgr")
AddPreloadFile("framework/logic/skill/skill_mgr")
AddPreloadFile("framework/logic/skill/skill_template")
AddPreloadFile("framework/logic/skill/skill_cast")
AddPreloadFile("framework/logic/skill/skill_effect")

AddPreloadFile("framework/logic/editor/gm")
AddPreloadFile("framework/logic/rpg/obj")
AddPreloadFile("framework/logic/rpg/calculator")

AddPreloadFile("framework/logic/component/move_node")
AddPreloadFile("framework/logic/component/passive_move_node")
AddPreloadFile("framework/logic/component/direction_move_node")
AddPreloadFile("framework/logic/component/bullet_node")
AddPreloadFile("framework/logic/component/cmd_node")
AddPreloadFile("framework/logic/component/ai_node")
AddPreloadFile("framework/logic/component/log_node")
AddPreloadFile("framework/logic/component/buff_node")
AddPreloadFile("framework/logic/component/cd_node")
AddPreloadFile("framework/logic/component/skill_node")
AddPreloadFile("framework/logic/component/action_node")
AddPreloadFile("framework/logic/component/movie_node")

AddPreloadFile("framework/cocos2d/resource_mgr")
AddPreloadFile("framework/cocos2d/ui")
AddPreloadFile("framework/cocos2d/menu")
AddPreloadFile("framework/cocos2d/sprite_sheets")
AddPreloadFile("framework/cocos2d/particles")
AddPreloadFile("framework/cocos2d/progress_bar")
AddPreloadFile("framework/cocos2d/scene_base")
AddPreloadFile("framework/cocos2d/scene_base_ex")
AddPreloadFile("framework/cocos2d/scene_mgr")
AddPreloadFile("framework/cocos2d/puppet")
AddPreloadFile("framework/cocos2d/spine_skelton")
AddPreloadFile("framework/cocos2d/skelton")
AddPreloadFile("framework/cocos2d/skelton_ex")
AddPreloadFile("framework/cocos2d/skelton_pool")
AddPreloadFile("framework/cocos2d/popo")

AddPreloadFile("framework/cocos2d/sample_scene/scene_list")


AddPreloadFile("framework/effects/fly_text")
AddPreloadFile("framework/effects/label_effect")
AddPreloadFile("framework/effects/effect_mgr")
AddPreloadFile(PROJECT_PATH.."/game_mgr")
