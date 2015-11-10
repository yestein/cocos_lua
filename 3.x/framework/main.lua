--===================================================
-- File Name    : main.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:54
-- Description  :
-- Modify       :
--===================================================

__platform = cc.Application:getInstance():getTargetPlatform()

-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    log_print("----------------------------------------")
    if SetConsoleError then
        SetConsoleError(1)
    end
    log_print("LUA ERROR: " .. tostring(msg) .. "\n")
    log_print(debug.traceback())
    if SetConsoleError then
        SetConsoleError(0)
    end
    log_print("----------------------------------------")
    -- log_print("进入调试模式")
    -- if __platform == cc.PLATFORM_OS_WINDOWS then
    --     debug.debug()
    -- end
end

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")
__write_path = cc.FileUtils:getInstance():getWritablePath()

local platform_name = {
    [cc.PLATFORM_OS_WINDOWS   ] = "Windows",
    [cc.PLATFORM_OS_LINUX     ] = "Linux",
    [cc.PLATFORM_OS_MAC       ] = "Mac",
    [cc.PLATFORM_OS_ANDROID   ] = "Android",
    [cc.PLATFORM_OS_IPHONE    ] = "iPhone",
    [cc.PLATFORM_OS_IPAD      ] = "iPad",
    [cc.PLATFORM_OS_BLACKBERRY] = "BlackBerry",
    [cc.PLATFORM_OS_NACL      ] = "nacl",
    [cc.PLATFORM_OS_EMSCRIPTEN] = "emscripten",
    [cc.PLATFORM_OS_TIZEN     ] = "tizen",
}

package.path = "./src/?.lua;" .. package.path
require("project")
require("logic_base/preload")
require("framework/preload")
require(PROJECT_PATH.."/preload")
assert(PreloadScript() == 1)

function InsertConsoleCmd(cmd_string)
    wait_execute_cmd_string = cmd_string
end

local function ExecuteCmdString(cmd_string)
    if cmd_string then
        if GBK2Utf8 then
            cmd_string = GBK2Utf8(cmd_string)
        end
        local cmd_func = loadstring(cmd_string)
        if cmd_func then
            xpcall(cmd_func, __G__TRACKBACK__)
        else
            cclog("Invalid CMD! %s", cmd_string)
        end
    end
end
local function MainLoop(delta)
    local fun = Stat:GetStatFunc("main loop")
    if FetchConsoleCmd then
        ExecuteCmdString(FetchConsoleCmd())
    end
    if wait_execute_cmd_string then
        ExecuteCmdString(wait_execute_cmd_string)
        wait_execute_cmd_string = nil
    end
    local tbModule = nil
    function ModulLoop()
        tbModule:OnLoop(delta)
    end

    tbModule = Physics
    xpcall(ModulLoop, __G__TRACKBACK__)

    tbModule = GameMgr
    xpcall(ModulLoop, __G__TRACKBACK__)

    tbModule = SceneMgr
    xpcall(ModulLoop, __G__TRACKBACK__)
    if fun then
        fun()
    end
end

if __platform == cc.PLATFORM_OS_WINDOWS then
    function OnWin32End()
        Exit()
    end
end

local function main()
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)
    log_print("main start")
    local director = cc.Director:getInstance()
    CCDirector:getInstance():setDisplayStats(true)

    if GameMgr.Preset then
        GameMgr:Preset()
    end

    visible_size = director:getVisibleSize()
    local glview = director:getOpenGLView()
    resolution_size = glview:getDesignResolutionSize()

    math.randomseed(os.time())
    math.random(100)
    DisplayRandom:Init(100)
    Event:Preload()
    assert(Debug:Init(Debug.MODE_BLACK_LIST) == 1)
    assert(ShaderMgr:Init() == 1)
    assert(SceneMgr:Init() == 1)
    if __Debug then
        assert(SceneMgr:CheckAllClass() == 1)
    end
    assert(Resource:Init() == 1)
    assert(Physics:Init() == 1)
    assert(Ui:Init() == 1)
    CCDirector:getInstance():getScheduler():scheduleScriptFunc(MainLoop, 0, false)
    log_print("================================================")
    log_print("Lua:", _VERSION)
    if __Debug == 1 then
        log_print("Mode:", "Debug")
    else
        log_print("Mode:", "Release")
    end
    log_print("Platform:", platform_name[__platform] or __platform)
    if CCVersion then
        log_print("Cocos2d: ", CCVersion())
    end
    log_print("Project:", PROJECT_PATH)


    if jit then
        log_print("LuaJIT: ", jit.version)
    end
    log_print(string.format("Resolution: %d * %d", resolution_size.width, resolution_size.height))
    log_print(string.format("Screen Size: %d * %d", visible_size.width, visible_size.height))
    log_print("================================================")
    assert(GameMgr:Init() == 1)
end

--This function will be called when the app is inactive. When comes a phone call,it's be invoked too
function DidEnterBackground()
    if GameMgr.DidEnterBackground then
        GameMgr:DidEnterBackground()
    end
end

--this function will be called when the app is active again
function WillEnterForeground()
    if GameMgr.WillEnterForeground then
        GameMgr:WillEnterForeground()
    end
end

function Exit()
    GameMgr:Uninit()
    Ui:Uninit()
    Physics:Uninit()
    SceneMgr:Uninit()
end
xpcall(main, __G__TRACKBACK__)
