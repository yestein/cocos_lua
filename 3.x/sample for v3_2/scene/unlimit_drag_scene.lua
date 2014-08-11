--=======================================================================
-- File Name    : unlimit_drag_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 18:07:07 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("SampleUnlimitDrag", 1)
Scene.property = {
	can_touch = 1,
	can_drag = 1,
}

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()
	local width, height = self:SetBackGroundImage({"sample_resource/farm.jpg", }, 1)
	return 1
end