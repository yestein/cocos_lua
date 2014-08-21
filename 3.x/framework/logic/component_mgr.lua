--=======================================================================
-- File Name    : compent_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/28 10:38:29
-- Description  : compnent_mgr
-- Modify       : 
--=======================================================================

if not ComponentMgr then
	ComponentMgr = {
		component_list = {}
	}
end

function ComponentMgr:CreateComponent(component_name)
	assert(not ComponentMgr.component_list[component_name])
	local class_module = NewLogicNode(component_name)
	ComponentMgr.component_list[component_name] = class_module
	return class_module
end

function ComponentMgr:CreateInheritComponent(component_name, parent_name)
	assert(not ComponentMgr.component_list[component_name])
	local parent_component = ComponentMgr.component_list[parent_name]
	assert(parent_component)
	local class_module = Class:New(parent_component, component_name)
	ComponentMgr.component_list[component_name] = class_module
	return class_module
end

function ComponentMgr:GetComponent(component_name)
	return ComponentMgr.component_list[component_name]
end

function ComponentMgr:NewComponent(component_name)
	local component = ComponentMgr:GetComponent(component_name)
	return Class:New(component, component_name.."_obj")
end

function ComponentMgr:Dump(n)
	Lib:ShowTB(self.component_list, n)
end