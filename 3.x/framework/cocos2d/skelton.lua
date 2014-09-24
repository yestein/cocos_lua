--=======================================================================
-- File Name    : skelton.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/22 13:57:33
-- Description  : 对 cocostudio skelton 进行的封装
-- Modify       : 
--=======================================================================

if not Skelton then
	Skelton = Class:New(Puppet, "SKELTON")
	Skelton.default_animation_name = {}
	Skelton.animation_name = {}
	Skelton.animation_next = {}
end

function Skelton:SetDefaultAnimationName(animation_name, resource_name)
	self.default_animation_name[animation_name] = resource_name
end

function Skelton:SetSkeltonAnimationName(skelton_name, animation_name, resource_name)
	if not self.animation_name[skelton_name] then
		self.animation_name[skelton_name] = {}
	end
	self.animation_name[skelton_name][animation_name] = resource_name
end

function Skelton:GetSkeltonAnimationName(skelton_name, animation_name)
	local animation_list = self.animation_list
	if not animation_list then
		animation_list = self.animation_name[skelton_name]
	end
	if not animation_list then
		animation_list = self.default_animation_name
	end
	local resource_name = animation_list[animation_name]
	if not resource_name then
		if self.animation_name[skelton_name] then
			resource_name = self.animation_name[skelton_name][animation_name]
		end
	end
	if not resource_name then
		resource_name = self.default_animation_name[animation_name]
	end
	return resource_name	
end

function Skelton:SetAnimationNext(skelton_name, resource_name, next_resource_name)
	if not self.animation_next[skelton_name] then
		self.animation_next[skelton_name] = {}
	end
	self.animation_next[skelton_name][resource_name] = next_resource_name
end

function Skelton:GetAnimationNext(resource_name)
	local skelton_name = self.skelton_name
	if not self.animation_next[skelton_name] then
		return
	end
	return self.animation_next[skelton_name][resource_name]
end

function NewSkelton(skelton_name, orgin_direction, param)
	if not skelton_name then
		assert(false, "skelton_name is nil")
		return
	end
	local skelton = Class:New(Skelton)
	if skelton:Init(skelton_name, nil, orgin_direction, param) ~= 1 then
		return 
	end
	return skelton
end

function Skelton:_Uninit()
	self.animation_func    = nil
	self.animation_speed   = nil
	self.frame_func        = nil
	self.current_animation = nil
	self.bone_diplay_index = nil
	self.bone_diplay_name  = nil
	Resource:UnloadSkelton(self.skelton_name)
	self.skelton_name      = nil

	return 1
end

function Skelton:_Init(name, sprite, orgin_direction, param)
	self.is_debug_boundingbox = param.is_debug_boundingbox	
	self.animation_speed = {}
	self.animation_func = {}
	self.frame_func = {}

	if self:SetArmature(name, orgin_direction, param) ~= 1 then
		return 0
	end

	self:PlayAnimation("normal")

	if self:IsDebugBoundingBox() == 1 then
		self:InitDebugBox()
	end
	return 1
end

function Skelton:SetArmature(skelton_name, orgin_direction, param)
	local armature = Resource:LoadSkelton(skelton_name)
	if not armature then
		return 0
	end
	self.skelton_name = skelton_name
	self.bone_diplay_name = {}
	self.bone_diplay_index = {}
	self.orgin_direction = orgin_direction

	if armature.getOffsetPoints then
		local offsetPoints = armature:getOffsetPoints()
		local rect = armature:getBoundingBox()
		local offset = Resource.bone_offset[skelton_name]
		if offset then
			armature:setAnchorPoint(cc.p(offsetPoints.x / rect.width + offset.x, offset.y))
		else
			armature:setAnchorPoint(cc.p(offsetPoints.x / rect.width, 0))
		end
	end
	self:AddChildElement("armature", armature, 0, 0, 1, 10)

	local function animationEvent(armature, movement_type, movement_id)
		if not self.animation_func[movement_id] then
			return
		end

		local func = self.animation_func[movement_id][movement_type]
		if not func then
			return
		end
		func(self, movement_type, movement_id)
    end
	armature:getAnimation():setMovementEventCallFunc(animationEvent)

	
	local function frameEvent(bone, event_name, origin_frame_index,current_frame_index)
		local func = self.frame_func[event_name]
		if not func then
			return
		end
		func(self, bone, origin_frame_index, current_frame_index)
	end
	armature:getAnimation():setFrameEventCallFunc(frameEvent)

	if param then
		if param.change_equip then
			for bone_name, index in pairs(param.change_equip) do
				if type(index) == "number" then
					self:ChangeBoneDisplay(bone_name, index)
				elseif type(index) == "string" then
					self:ChangeBoneDisplayByName(bone_name, index)
				end
			end
		end

		if param.hide_bone then
			for bone_name, _ in pairs(param.hide_bone) do
				self:SetBoneVisible(bone_name, false)
			end
		end
		if param.animation_list then
			self.animation_list = param.animation_list
		end
	end
	if param.scale then
		self:GetArmature():setScale(param.scale)
	end	
	return 1
end

function Skelton:GetBoundingBox()
	local rect = self:GetArmature():getBoundingBox()
	local x, y = self.sprite:getPosition()
	rect.x = rect.x + x
	rect.y = rect.y + y
	return rect
end

function Skelton:GetArmature()
	return self:GetChildElement("armature")
end

function Skelton:SetAnimationFunc(movement_type, animation_name, func)
	local skelton_name = self.skelton_name
	local animation_list = self.animation_list
	if not animation_list then
		animation_list = self.animation_name[skelton_name]
	end
	if not animation_list then
		animation_list = self.default_animation_name
	end
	local resource_name = animation_list[animation_name]
	if not resource_name then
		if self.animation_name[skelton_name] then
			resource_name = self.animation_name[skelton_name][animation_name]
		end
	end
	if not resource_name then
		resource_name = self.default_animation_name[animation_name]
	end

	if type(resource_name) == "string" then
		local movement_id = resource_name
		self:SetMoveMentFunc(movement_type, movement_id, func)
	elseif type(resource_name) == "table" then
		for _, movement_id in ipairs(resource_name) do
			self:SetMoveMentFunc(movement_type, movement_id, func)
		end
	end
end

function Skelton:SetMoveMentFunc(movement_type, movement_id, func)
	if not self.animation_func[movement_id] then
		self.animation_func[movement_id] = {}
	end
	self.animation_func[movement_id][movement_type] = func
end

function Skelton:SetFrameFunc(event_name, func)
	self.frame_func[event_name] = func
end

function Skelton:SetAnimationSpeed(animation_name, speed_scale)
	self.animation_speed[animation_name] = speed_scale
	if self:GetCurrentAnimation() == animation_name then
		self:GetArmature():getAnimation():setSpeedScale(speed_scale)
	end
end

function Skelton:GetAnimationSpeed(animation_name)
	return self.animation_speed[animation_name] or 1
end

function Skelton:GetAnimationResourceName(animation_name)
	local resource_name = self:GetSkeltonAnimationName(self.skelton_name, animation_name)
	if type(resource_name) == "string" then
		return resource_name
	elseif type(resource_name) == "table" then
		if self.animation_next[self.skelton_name] then
			return resource_name[1]
		else
			local random_index = math.random(1, #resource_name)
			return resource_name[random_index]
		end
	end
end

function Skelton:PlayAnimation(animation_name, duration_frame, is_loop)
	local resource_name = self:GetAnimationResourceName(animation_name)
	if not resource_name then
		print(string.format("No Animation[%s]", animation_name))
		return
	end
	local speed_scale = self:GetAnimationSpeed(animation_name)
	if speed_scale then
		self:GetArmature():getAnimation():setSpeedScale(speed_scale)
	end
	self:GetArmature():getAnimation():play(resource_name, duration_frame or -1, is_loop or -1)
	self.current_animation = animation_name
end

function Skelton:PlayRawAnimation(resource_name, duration_frame, is_loop)
	self:GetArmature():getAnimation():play(resource_name, duration_frame or -1, is_loop or -1)
end

function Skelton:GetCurrentAnimation()
	return self.current_animation
end

function Skelton:MoveTo(target_x, target_y, during_time)
	local x, y = self.sprite:getPosition()
	local function playStop()
		if self:GetCurrentAnimation() == "run" then
			self:PlayAnimation("normal")
		end
	end
	if self:GetCurrentAnimation() ~= "run" then
		self:PlayAnimation("run")
	end
	local move_action = cc.MoveBy:create(during_time, cc.p(target_x - x, target_y - y))
	local play_stop = cc.CallFunc:create(playStop)
	local sequece_action = cc.Sequence:create(move_action, play_stop)
	sequece_action:setTag(Def.TAG_MOVE_ACTION)
	self.sprite:stopActionByTag(Def.TAG_MOVE_ACTION)
	self.sprite:runAction(sequece_action)
end

function Skelton:InitDebugBox()
	local draw_node = self:GetChildElement("box")
	if not draw_node then
		draw_node = cc.DrawNode:create()

		local rect = self:GetArmature():getBoundingBox()
		draw_node:drawPolygon(
			{cc.p(rect.x, rect.y), cc.p(rect.x + rect.width, rect.y), 
			cc.p(rect.x + rect.width, rect.y + rect.height), cc.p(rect.x, rect.y+ rect.height),},
			4, 
			cc.c4b(0, 0, 0, 0),
			1,
			cc.c4b(0, 1, 0, 1)
		)
		draw_node:setLocalZOrder(10000)
		draw_node:drawDot(cc.p(0, 0), 7, cc.c4b(1, 0, 0, 1))
		self:AddChildElement("box", draw_node, 0, 0, 1)

		local dot_node = cc.DrawNode:create()
		dot_node:drawDot(cc.p(0, 0), 5, cc.c4b(0, 0, 1, 1))
		self:GetArmature():addChild(dot_node, 10000)
	end
end

function Skelton:IsDebugBoundingBox()
	return self.is_debug_boundingbox
end

function Skelton:SetBoneColor(bone_name, color)
	local bone = self:GetArmature():getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end
	bone:getDisplayRenderNode():setColor(color)
end

function Skelton:AddParticles(bone_name, particles_name, scale)
	local bone = self:GetArmature():getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end

	local particles_bone_name = bone_name.."_"..particles_name

	if not self.bone_particles then
		self.bone_particles = {}
	end
	if self.bone_particles[particles_bone_name] then
		assert(false, "Particles[%s] already Exists!!!", self.bone_particles[particles_bone_name])
		return
	end

	local particles = Particles:CreateParticles(particles_name)		
	local particles_bone = ccs.Bone:create(particles_bone_name)
    particles_bone:addDisplay(particles, 0)
    particles_bone:changeDisplayWithIndex(0, true)
    particles_bone:setIgnoreMovementBoneData(true)
    particles_bone:setLocalZOrder(100)
    if scale then
    	particles_bone:setScale(scale)
    end

    self:GetArmature():addBone(particles_bone, bone_name)
    self.bone_particles[particles_bone_name] = particles_bone

    return 1
end

function Skelton:RemoveParticles(bone_name, particles_name)
	local bone = self:GetArmature():getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end
	if not self.bone_particles then
		assert(false, "no bone particles")
		return
	end
	local particles_bone_name = bone_name.."_"..particles_name

	if not self.bone_particles[particles_bone_name] then
		assert(false, "no particles bone[%s]", particles_bone_name)
		return
	end


	local particles_bone = self.bone_particles[particles_bone_name]
	self:GetArmature():removeBone(particles_bone, true)
	self.bone_particles[particles_bone_name] = nil
end

function Skelton:AddBoneDisplay(bone_name, sprite)
	--TODO
end

function Skelton:SetBoneVisible(bone_name, is_visible)
	local bone = self:GetArmature():getBone(bone_name)
	bone:getDisplayRenderNode():setVisible(is_visible)
end

function Skelton:ChangeBoneDisplay(bone_name, index)
	self.bone_diplay_index[bone_name] = index + 1
	local bone = self:GetArmature():getBone(bone_name)
	bone:changeDisplayWithIndex(index, true)
end

function Skelton:GetBoneDisplayIndex(bone_name)
	local index = self.bone_diplay_index[bone_name] or 1
	return index - 1
end

function Skelton:ChangeBoneDisplayByName(bone_name, display_name)
	self.bone_diplay_name[bone_name] = display_name
	local bone = self:GetArmature():getBone(bone_name)
	bone:changeDisplayWithName(display_name, true)
end

function Skelton:GetBoneDisplayName(bone_name)
	return self.bone_diplay_name[bone_name]
end

function Skelton:ReplaceArmature(skelton_name, orgin_direction, param)
	local old_armature = self:GetArmature()
	local old_skelton_name = self.skelton_name
	local old_animation_list = {}
	for animation_name, _ in pairs(self.default_animation_name) do
		old_animation_list[animation_name] = self:GetSkeltonAnimationName(self.skelton_name, animation_name)
	end
	
	if self:SetArmature(skelton_name, orgin_direction, param) ~= 1 then
		return 0
	end
	if old_armature then
		self.sprite:removeChild(old_armature, true)
	end

	for animation_name, old_resource_name in pairs(old_animation_list) do
		local new_resource_name = self:GetSkeltonAnimationName(self.skelton_name, animation_name)
		if old_resource_name ~= new_resource_name then
			if self.animation_func[old_resource_name] then
				self.animation_func[new_resource_name] = self.animation_func[old_resource_name]
				self.animation_func[old_resource_name] = nil
			end
		end
	end
	self:SetDirection(self.logic_direction)
	self:PlayAnimation("normal")
	Event:FireEvent("SKELTON.REPLACE", old_skelton_name, self.skelton_name)
	return 1
end