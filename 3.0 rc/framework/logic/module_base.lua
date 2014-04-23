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
		active_module = {},
	}
end

function ModuleMgr:NewModule(module_name)
	assert(not self.module_list[module_name])
	local class_module = Lib:NewClass(ModuleBase)
	class_module.__name = module_name
	self.module_list[module_name] = class_module
	return class_module
end

function ModuleMgr:GetModule(module_name)
	return self.module_list[module_name]
end

function ModuleMgr:ForEachActiveModule(func)
	for module, active_func in pairs(self.active_module) do
		func(module, active_func)
	end
end

function ModuleMgr:RegisterActive(module_name, fun_name)
	local active_module = self.module_list[module_name]
	assert(active_module)
	local active_function = active_module[fun_name]
	assert(active_function)
	self.active_module[active_module] = active_function
end

function ModuleMgr:UnregisterActive(module_name)
	self.active_module[module_name] = nil
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


