--=======================================================================
-- File Name    : module_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 16:16:44 2014
-- Description  :
-- Modify       :
--=======================================================================

if not ModuleMgr then
	ModuleMgr = {
		module_list = {},
	}
end

function ModuleMgr:NewModule(module_name)
	assert(not module_list[module_name])
	local class_module = Lib:NewClass(ModuleBase)
	class_module.__name = module_name
	module_list[module_name] = class_module
	return class_module
end

if not ModuleBase then
	ModuleBase = Lib:NewClass(LogicNode)
end

function ModuleBase:Init(...)
	self:RegisterEventListen()
	self:_Init(...)
end

function ModuleBase:Uninit( ... )
	self:_Uninit(...)
	self:UninitChild()
	self:UnregisterEventListen()
	self.__name = nil
end

function ModuleBase:GetName()
	return self.__name
end


