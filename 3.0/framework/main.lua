--===================================================
-- File Name    : main.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:06:54
-- Description  :
-- Modify       :
--===================================================


-- for CCLuaEngine traceback
function __G__TRACKBACK__(msg)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(msg) .. "\n")
    print(debug.traceback())
    print("----------------------------------------")
end

cc.FileUtils:getInstance():addSearchPath("src")
cc.FileUtils:getInstance():addSearchPath("res")

require("project.lua")
require("framework/preload.lua")
require(PROJECT_PATH.."/preload.lua")
PreloadScript()

function cclog(...)
    print(string.format(...))
end

local function MainLoop(delta)
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
end

if device == "win32" then
	function OnWin32End()
		Exit()
	end
end

local function main()
	-- avoid memory leak
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	print("main start")
	
	-- play background music, preload effect
	
	-- uncomment below for the BlackBerry version
	-- local bgMusicPath = sharedFileUtils:fullPathForFilename("background.ogg")
	-- local bgMusicPath = sharedFileUtils:fullPathForFilename("1.mp3")
	-- sharedEngine:playBackgroundMusic(bgMusicPath, true)
	-- local effectPath = sharedFileUtils:fullPathForFilename("effect1.wav")
	-- sharedEngine:preloadEffect(effectPath)
	
	math.randomseed(os.time())
	math.random(100)
	Event:Preload()
    Debug:Init(Debug.MODE_BLACK_LIST)
    
    SceneMgr:Init()
    if _DEBUG then
    	assert(SceneMgr:CheckAllClass() == 1)
    end
    Physics:Init()
    Ui:Init()
    CCDirector:getInstance():setDisplayStats(true)
    CCDirector:getInstance():getScheduler():scheduleScriptFunc(MainLoop, 0, false)

    GameMgr:Init()
end

--This function will be called when the app is inactive. When comes a phone call,it's be invoked too
function DidEnterBackground()
	-- body
end

--this function will be called when the app is active again
function WillEnterForeground()
	-- body
end

function Exit()
	GameMgr:Uninit()
	Ui:Uninit()
	Physics:Uninit()
	SceneMgr:Uninit()
	Net:Uninit()
end
xpcall(main, __G__TRACKBACK__)