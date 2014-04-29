--=======================================================================
-- File Name    : obj_pool.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2014-03-02 16:14:23
-- Description  :
-- Modify       :
--=======================================================================

if not ObjPool then
	ObjPool = {}
end

function ObjPool:Init(obj_name)
	self.obj_pool = {}
	self.next_id = 1
	self.obj_name = obj_name
end

function ObjPool:Uninit()
	self.obj_pool = nil
	self.next_id = nil
end

function ObjPool:Add(obj_template, ...)
	local obj = Lib:NewClass(obj_template)
	local id = self.next_id
	if obj:Init(id, ...) == 1 then
		self.obj_pool[id] = obj
		self.next_id = self.next_id + 1
		Event:FireEvent(self.obj_name.."Add", id, ...)
		return obj, id
	end
end

function ObjPool:Remove(id)
	if not id or not self.obj_pool[id] then
		return 0
	end

	Event:FireEvent(self.obj_name.."Remove", id)
	if self.obj_pool[id]:Uninit() ~= 1 then
		return 0
	end
	self.obj_pool[id] = nil
	return 1
end

function ObjPool:GetById(id)
	if not id then
		return
	end
	return self.obj_pool[id]
end

function ObjPool:ResetId()
	self.next_id = 1
end

function ObjPool:RemoveAll(callback)
	for id, obj in pairs(self.obj_pool) do
		if callback then
			callback(id, obj)
		end
		self:Remove(id)
	end
end
