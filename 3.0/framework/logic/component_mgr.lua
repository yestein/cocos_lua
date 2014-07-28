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

function CreateComponent(component_name)
	assert(not ComponentMgr.component_list[component_name])
	local class_module = NewLogicNode(component_name)
	ComponentMgr.component_list[component_name] = class_module
	return class_module
end

function GetComponent(component_name)
	return ComponentMgr.component_list[component_name]
end

function NewComponent(component_name)
	local component = GetComponent(component_name)
	return Class:New(component, component_name.."_obj")
end