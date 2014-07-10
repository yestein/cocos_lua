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
	local sprite = skelton:GetSprite()
	self.scene:AddObj(layer_name, "skelton", id, sprite)
	self.skelton_list[id] = {skelton, layer_name}
	return skelton
end

function SkeltonPool:GetById(id)
	local one = self.skelton_list[id]
	if one then
		return unpack(one)
	end
end

function SkeltonPool:ForEach(call_back, ...)
	if self.skelton_list then
		for id, obj in pairs(self.skelton_list) do
			local ret = call_back(id, obj[1], obj[2], ...)
			if ret == 0 then
				return
			end
		end
	end
end

function SkeltonPool:RemoveById(id)
	local skelton, layer_name = self:GetById(id)
	if skelton then
		self.scene:RemoveObj(layer_name, "skelton", id, true)
		skelton:Uninit()		
		self.skelton_list[id] = nil
	end
end