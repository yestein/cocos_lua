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
local file_utils = cc.FileUtils:getInstance()
local sprite_frame_cache = cc.SpriteFrameCache:getInstance()
local armature_data_manager = ccs.ArmatureDataManager:getInstance()
local audio_engine = cc.SimpleAudioEngine:getInstance()

function Resource:Init()
	self.loaded_skelton = {}
	return 1
end

function Resource:LoadSpriteSheets(folder_name, animation_name_list)
	for _, animation_name in pairs(animation_name_list) do
		local plist_file = folder_name.."/".. animation_name .. ".plist"
		sprite_frame_cache:addSpriteFrames(plist_file)
	end
end

function Resource:UnloadSpriteSheets(folder_name, animation_name_list)
	for _, animation_name in pairs(animation_name_list) do
		local plist_file = folder_name.."/".. animation_name .. ".plist"
		sprite_frame_cache:addSpriteFrames(plist_file)
	end
end

function Resource:SetSkeltonFolder(folder_name)
	self.skelton_folder_name = folder_name
end

function Resource:LoadSkelton(skelton_name)
	if not self.loaded_skelton[skelton_name] then
		local prefix_file_name = self.skelton_folder_name .. "/" .. skelton_name .. "/" .. skelton_name
		local png_file = prefix_file_name .. "0.png"
		local plist_file = prefix_file_name .. "0.plist"
		local json_file = prefix_file_name .. ".ExportJson"
		armature_data_manager:addArmatureFileInfo(png_file, plist_file, json_file)
		self.loaded_skelton[skelton_name] = 0
	end
	self.loaded_skelton[skelton_name] = self.loaded_skelton[skelton_name] + 1
	return ccs.Armature:create(skelton_name)
end

function Resource:UnloadSkelton(skelton_name)
	self.loaded_skelton[skelton_name] = self.loaded_skelton[skelton_name] - 1
	if self.loaded_skelton[skelton_name] == 0 then
		local prefix_file_name = self.skelton_folder_name .. "/" .. skelton_name .. "/" .. skelton_name
		local json_file = prefix_file_name .. ".ExportJson"
		armature_data_manager:removeArmatureFileInfo(json_file)
		self.loaded_skelton[skelton_name] = nil
	end
end


function Resource:LoadParticles(particles_name, file_path)
	if not self.particles_list then
		self.particles_list = {}
	end
	assert(not self.particles_list[particles_name])
	self.particles_list[particles_name] = file_path
end

function Resource:UnloadParticles(particles_name, file_path)
	if not self.particles_list then
		self.particles_list = {}
	end
	assert(not self.particles_list[particles_name])
	self.particles_list[particles_name] = file_path
end

function Resource:GetParticlesFile(particles_name)
	return self.particles_list[particles_name]
end

function Resource:LoadSoundEffect(file_path)
	local full_path = file_utils:fullPathForFilename(file_path)
    return audio_engine:preloadEffect(full_path)
end

function Resource:UnloadSoundEffect(file_path)
	local full_path = file_utils:fullPathForFilename(file_path)
    return audio_engine:unloadEffect(full_path)
end

function Resource:StopSoundEffect(effect_id)
	return audio_engine:stopEffect(effect_id)
end

function Resource:PlaySoundEffect(file_path)
	local full_path = file_utils:fullPathForFilename(file_path)
	return audio_engine:playEffect(full_path)
end