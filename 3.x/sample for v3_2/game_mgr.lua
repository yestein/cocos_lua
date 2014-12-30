--=======================================================================
-- File Name    : game_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 19:01:05 2014
-- Description  : sample game mgr
-- Modify       :
--=======================================================================

function GameMgr:Preset()
	local director = cc.Director:getInstance()
    local glview = director:getOpenGLView()
    if nil == glview then
        glview = cc.GLView:createWithRect("sample 3.2", cc.rect(0, 0, 1136,640))
        director:setOpenGLView(glview)
    end

    glview:setDesignResolutionSize(1136, 640, cc.ResolutionPolicy.SHOW_ALL)
    -- turn on display FPS
    director:setDisplayStats(true)

    --set FPS. the default value is 1.0/60 if you don't call this
    director:setAnimationInterval(1.0 / 60)
end

function GameMgr:_Init()
	SceneMgr:FirstLoadScene("Sample")
	return 1
end

