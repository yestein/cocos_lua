--=======================================================================
-- File Name    : data_center.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Mon May 12 19:15:05 2014
-- Description  :
-- Modify       :
--=======================================================================

if not DataCenter then
	DataCenter = {}
end

function DataCenter:GetSaveData()
	local save_data = {}
	for module_name, class_module in pairs(ModuleMgr.module_list) do
		if class_module.GetSaveData then
			save_data[module_name] = class_module:GetSaveData()
		end
	end
	return save_data
end

function DataCenter:LoadData(load_data)
	for module_name, module_data in pairs(load_data) do
		local load_module = ModuleMgr:GetModule(module_name)
		load_module:Load(module_data)
	end
	return save_data
end