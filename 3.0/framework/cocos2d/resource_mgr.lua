--=======================================================================
-- File Name    : resource.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/16 14:04:26
-- Description  : Manage All Game Resource Data
-- Modify       : 
--=======================================================================

if not Resource then
	Resource = {}
end

function Resource:LoadSpriteSheets(folder_name, animation_name_list)
	local cache = cc.SpriteFrameCache:getInstance()
	for _, animation_name in pairs(animation_name_list) do
		local plist_file = folder_name.."/".. animation_name .. ".plist"
		cache:addSpriteFrames(plist_file)
	end
end

function Resource:LoadBoneAnimation(folder_name, animation_name_list)
	local armature_data_manager = ccs.ArmatureDataManager:getInstance()
	for _, animation_name in pairs(animation_name_list) do
		local png_file = folder_name.."/".. animation_name .. "0.png"
		local plist_file = folder_name.."/".. animation_name .. "0.plist"
		local json_file = folder_name.."/".. animation_name .. ".ExportJson"
		armature_data_manager:addArmatureFileInfo(png_file, plist_file, json_file)
	end
end