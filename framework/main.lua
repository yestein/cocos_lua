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

require("framework/preload.lua")
require("script/preload.lua")
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

	tbModule = SceneMgr
	xpcall(ModulLoop, __G__TRACKBACK__)

	tbModule = GameMgr
	xpcall(ModulLoop, __G__TRACKBACK__)
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
    MenuMgr:Init()
    Physics:Init()
    Ui:Init()
    CCDirector:getInstance():getScheduler():scheduleScriptFunc(MainLoop, 0, false)

    GameMgr:Init()
end

xpcall(main, __G__TRACKBACK__)