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

log_print = function(...)
    print(...)
end

dbg_print = function(...)
    print(...)
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
    dbg_print("old path", raw_package_path)
    local new_package_path = ""
    for path, _ in pairs(g_addition_package_path) do
        new_package_path = string.format("%s/?.lua;", path) .. new_package_path
    end
    package.path = new_package_path .. raw_package_path
    dbg_print("Package Path", package.path)
    for _, script_file in ipairs(g_script_list) do
        dbg_print("loading \""..script_file.."\"")
        require(script_file)
    end
    for name, func in pairs(g_init_funciton) do
        dbg_print(name, "Execute...")
        local result, ret_code = Lib:SafeCall({func})
        if not result or ret_code ~= 1 then
            assert(false, "%s execute failed", name)
            return 0
        end
    end
    return 1
end

function ReloadScript()
    dbg_print("Reload Lua Script...")
    for _, script_file in ipairs(g_script_list) do
        package.loaded[script_file]  = nil
        require(script_file)
        dbg_print("Reload\t["..script_file.."]")
    end

    for name, func in pairs(g_init_funciton) do
        dbg_print(name, "Execute...")
        local result, ret_code = Lib:SafeCall({func})
        if not result or ret_code ~= 1 then
            assert(false, "%s execute failed", name)
            return 0
        end
    end
    return 1
end

AddPreloadFile("logic_base/calculator")
AddPreloadFile("logic_base/class")
AddPreloadFile("logic_base/component_mgr")
AddPreloadFile("logic_base/data_center")
AddPreloadFile("logic_base/dbg")
AddPreloadFile("logic_base/event")
AddPreloadFile("logic_base/lib")
AddPreloadFile("logic_base/config_parser")
AddPreloadFile("logic_base/log")
AddPreloadFile("logic_base/logic_node")
AddPreloadFile("logic_base/module_mgr")
AddPreloadFile("logic_base/movie")
AddPreloadFile("logic_base/obj_base")
AddPreloadFile("logic_base/obj_pool")

AddPreloadFile("logic_base/pick_helper")
AddPreloadFile("logic_base/slide_helper")
AddPreloadFile("logic_base/slide_count_helper")
AddPreloadFile("logic_base/stat")

AddPreloadFile("logic_base/timer_base")
AddPreloadFile("logic_base/wait_helper")

AddPreloadFile("logic_base/component/action_node")
AddPreloadFile("logic_base/component/buff_node")
AddPreloadFile("logic_base/component/cd_node")
AddPreloadFile("logic_base/component/cmd_node")
AddPreloadFile("logic_base/component/direction_move_node")
AddPreloadFile("logic_base/component/log_node")
AddPreloadFile("logic_base/component/move_node")
AddPreloadFile("logic_base/component/movie_node")
AddPreloadFile("logic_base/component/skill_node")

AddPreloadFile("logic_base/buff/buff_base")
AddPreloadFile("logic_base/buff/buff_mgr")

AddPreloadFile("logic_base/editor/gm")

AddPreloadFile("logic_base/skill/skill_mgr")
AddPreloadFile("logic_base/skill/skill_template")
AddPreloadFile("logic_base/skill/skill_cast")
AddPreloadFile("logic_base/skill/skill_effect")
