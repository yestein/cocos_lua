--=======================================================================
-- File Name    : bgm_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 18:07:07 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("SampleBGM", 1)
Scene.property = {
	can_touch = 1,
	can_drag = 1,
}

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()
	self:SetBGM("sample_resource/background.mp3")
	return 1
end