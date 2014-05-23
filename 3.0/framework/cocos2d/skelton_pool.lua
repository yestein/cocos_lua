--=======================================================================
-- File Name    : skelton_pool.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/22 14:58:14
-- Description  : manage skelton
-- Modify       : 
--=======================================================================
local SkeltonPool = {}

function NewSkeltonPool(scene_name)
	local pool = Class:New(SkeltonPool)
	pool:Init(scene_name)
	return pool
end

function SkeltonPool:_Uninit()
	for id, _ in pairs(self.skelton_list) do
		self:RemoveById(id)
	end
	self.skelton_list = nil
	self.scene = nil
end

function SkeltonPool:_Init(scene_name)
	self.scene = SceneMgr:GetScene(scene_name)
	self.skelton_list = {}
end

function SkeltonPool:Create(layer_name, id, skelton_name, orgin_direction, param)
	assert(not self.skelton_list[id])
	local skelton = NewSkelton(skelton_name, orgin_direction, param)
	if not skelton then
		return
	end
	local armature = skelton:GetArmature()
	local obj_name = "skelton"..id
	self.scene:AddObj(layer_name, obj_name, armature)
	self.skelton_list[id] = {skelton, layer_name}
	return skelton
end

function SkeltonPool:GetById(id)
	local one = self.skelton_list[id]
	if one then
		return unpack(one)
	end
end

function SkeltonPool:RemoveById(id)
	local skelton, layer_name = self:GetById(id)
	if skelton then
		local obj_name = "skelton"..id
		self.scene:RemoveObj(layer_name, obj_name, true)
		skelton:Uninit()		
		self.skelton_list[id] = nil
	end
end