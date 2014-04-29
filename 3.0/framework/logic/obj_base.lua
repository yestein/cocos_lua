--=======================================================================
-- File Name    : obj_base.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 
-- Description  :
-- Modify       :
--=======================================================================

if not ObjBase then
	ObjBase = Lib:NewClass(LogicNode)
end

function ObjBase:Init(id, ...)
	self.id = id

	return self:_Init(...) 
end

function ObjBase:Uninit()
	if self:_Uninit() ~= 1 then
		return 0
	end
	self:UninitChild()
	self.id = nil
	return 1
end

function ObjBase:GetId()
	return self.id
end
