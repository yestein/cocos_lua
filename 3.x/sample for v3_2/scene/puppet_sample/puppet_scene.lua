--=======================================================================
-- File Name    : puppet_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/12/30 16:35:58
-- Description  : puppet test case
-- Modify       : 
--=======================================================================
local Scene = SceneMgr:GetClass("PuppetSample", 1)
Scene.property = {
	can_touch = 1,
	can_drag = 1,
}

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()
	local sprite = cc.Sprite:create("sample_resource/land.png")
	local puppet = NewPuppet("test", "left")
	puppet:SetSprite(sprite)
	self:AddObj("main", "puppet", "test", sprite)
	sprite:setPosition(visible_size.width / 2, visible_size.height / 2)
	self.puppet = puppet

	local rect = puppet:GetBoundingBox()

	local child_sprite_1 = cc.Sprite:create("sample_resource/menu1.png")
	puppet:AddChildElement("icon1", child_sprite_1)
	child_sprite_1:setLocalZOrder(-1)
	child_sprite_1:setPosition(10, 0)

	local child_sprite_2 = cc.Sprite:create("sample_resource/menu1.png")
	puppet:AddChildElement("icon2", child_sprite_2, 1)
	child_sprite_2:setLocalZOrder(1)
	child_sprite_2:setPosition(0, rect.height)
	return 1
end

function Scene:OnTouchEnded(x, y)
	-- body
end

function Scene:OnTouchMoved(x, y)
	-- body
end

function Scene:OnTouchEnded(x, y)
	if self.puppet:GetLogicDirection() == "left" then
		self.puppet:SetDirection("right")
	else
		self.puppet:SetDirection("left")
	end
end