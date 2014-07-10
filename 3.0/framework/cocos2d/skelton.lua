--=======================================================================
-- File Name    : skelton.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/22 13:57:33
-- Description  : 对 cocostudio skelton 进行的封装
-- Modify       : 
--=======================================================================

if not Skelton then
	Skelton = Class:New(nil, "SKELTON")
	Skelton.default_animation_name = {}
	Skelton.animation_name = {}
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
	local animation_list = self.animation_name[skelton_name]
	if not animation_list then
		animation_list = self.default_animation_name
	end
	local resource_name = animation_list[animation_name]
	if not resource_name then
		resource_name = self.default_animation_name[animation_name]
	end
	if type(resource_name) == "string" then
		return resource_name
	elseif type(resource_name) == "table" then
		local random_index = math.random(1, #resource_name)
		return resource_name[random_index]
	end
end

function NewSkelton(skelton_name, orgin_direction, param)
	if not skelton_name then
		assert(false, "skelton_name is nil")
		return
	end
	local skelton = Class:New(Skelton)
	if skelton:Init(skelton_name, orgin_direction, param) ~= 1 then
		return 
	end
	return skelton
end

function Skelton:_Uninit()
	self.orgin_direction        = nil
	self.armature               = nil
	self.animation_func			= nil
	self.animation_speed		= nil
	self.animation_replace_name = nil	
	self.animation_func         = nil
	self.frame_func             = nil
	self.current_animation      = nil
	self.raw_scale 				= nil
	self.child_list				= nil
end

function Skelton:_Init(skelton_name, orgin_direction, param)
	local armature = ccs.Armature:create(skelton_name)
	if not armature then
		return 0
	end
	self.sprite = cc.Sprite:create()
	self.child_list = {}
	self.skelton_name = skelton_name
	self.raw_scale = 1
	self.direction = 1
	self.orgin_direction = orgin_direction	
	local offsetPoints = armature:getOffsetPoints()
	local rect = armature:getBoundingBox()
	local offset = Resource.bone_offset[skelton_name]
	if offset then
		armature:setAnchorPoint(cc.p(offsetPoints.x / rect.width + offset.x, offset.y))
	else
		armature:setAnchorPoint(cc.p(offsetPoints.x / rect.width, 0))
	end
	self.sprite:addChild(armature)
	self.armature = armature
	self.animation_replace_name = {}
	self.animation_speed = {}

	self.animation_func = {}
	local function animationEvent(armature, movement_type, movement_id)
		if not self.animation_func[movement_id] then
			return
		end

		local func = self.animation_func[movement_id][movement_type]
		if not func then
			return
		end
		func(self, armature)
    end
	armature:getAnimation():setMovementEventCallFunc(animationEvent)

	self.frame_func = {}
	local function frameEvent(bone, event_name, origin_frame_index,current_frame_index)
		local func = self.frame_func[event_name]
		if not func then
			return
		end

		func(self, bone, origin_frame_index, current_frame_index)
	end
	armature:getAnimation():setFrameEventCallFunc(frameEvent)

	if param then
		if param.scale then
			self.raw_scale = param.scale
			self.armature:setScale(self.raw_scale)
		end
	end
	self.scale = 1

	self:PlayAnimation("normal")
	return 1
end

function Skelton:GetSprite()
	return self.sprite
end

function Skelton:GetBoundingBox()
	local rect = self.armature:getBoundingBox()
	local x, y = self.sprite:getPosition()
	rect.x = rect.x + x
	rect.y = rect.y + y
	return rect
end

function Skelton:SetAnchorPoint(anchor_point)
	self.sprite:setAnchorPoint(anchor_point)
end

function Skelton:SetPosition(x, y)
	self.sprite:setPosition(x, y)
end

function Skelton:SetLocalZOrder(order)
	self.sprite:setLocalZOrder(order)
end

function Skelton:AddChildElement(name, child)
	if self.child_list[name] then
		assert(false, "Child[%s] Already Exists", name)
		return
	end
	self.child_list[name] = child
	self.sprite:addChild(child)
end

function Skelton:GetChildElement(name)
	return self.child_list[name]
end

function Skelton:RemoveChildElement(name)
	if not self.child_list[name] then
		assert(false, "No Child[%s]", name)
		return
	end	
	self.sprite:removeChild(self.child_list[name], true)
	self.child_list[name] = nil
end

function Skelton:GetArmature()
	return self.armature
end

function Skelton:SetAnimationFunc(movement_type, animation_name, func)
	local animation_list = self.animation_name[self.skelton_name]
	if not animation_list then
		animation_list = self.default_animation_name
	end
	local resource_name = animation_list[animation_name]
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
		self.armature:getAnimation():setSpeedScale(speed_scale)
	end
end

function Skelton:GetAnimationSpeed(animation_name)
	return self.animation_speed[animation_name] or 1
end

function Skelton:GetAnimationResourceName(animation_name)
	return self:GetSkeltonAnimationName(self.skelton_name, animation_name)
end

function Skelton:PlayAnimation(animation_name, duration_frame, is_loop)
	local resource_name = self:GetAnimationResourceName(animation_name)
	if not resource_name then
		cclog("No Animation[%s]", animation_name)
		return
	end
	local speed_scale = self:GetAnimationSpeed(animation_name)
	self.armature:getAnimation():setSpeedScale(speed_scale)
	self.armature:getAnimation():play(resource_name, duration_frame or -1, is_loop or -1)
	self.current_animation = animation_name
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

function Skelton:SetScale(scale_rate, during_time)
	self.scale = scale_rate
	local sprite = self.sprite
	if during_time then
		local scale_action = cc.ScaleTo:create(during_time, self.scale)
		scale_action:setTag(Def.TAG_SCALE_ACTION)
		sprite:runAction(scale_action)
	else
		sprite:setScale(self.scale)
	end
end

function Skelton:UpdateDebugBox()

	local draw_node = self:GetChildElement("box")
	if not draw_node then
		draw_node = cc.DrawNode:create()

		local rect = self.armature:getBoundingBox()
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
		self:AddChildElement("box", draw_node)

		local dot_node = cc.DrawNode:create()
		dot_node:drawDot(cc.p(0, 0), 5, cc.c4b(0, 0, 1, 1))
		self.armature:addChild(dot_node, 10000)
	end

	draw_node:setScaleX(self.direction)
end

function Skelton:GetDirection()
	return self.direction
end

function Skelton:SetDirection(direction)
	if direction == self.orgin_direction then
		self.direction = 1
	else
		self.direction = -1
	end
	local armature = self.armature
	armature:setScaleX(self.raw_scale * self.direction)
end

function Skelton:SetBoneColor(bone_name, color)
	local bone = self.armature:getBone(bone_name)
	if not bone then
		assert(false, "[%s] have no Bone[%s]", self.skelton_name, bone_name)
		return
	end
	bone:getDisplayRenderNode():setColor(color)
end

function Skelton:AddParticles(bone_name, particles_name, scale)
	local bone = self.armature:getBone(bone_name)
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

    self.armature:addBone(particles_bone, bone_name)
    self.bone_particles[particles_bone_name] = particles_bone

    return 1
end

function Skelton:RemoveParticles(bone_name, particles_name)
	local bone = self.armature:getBone(bone_name)
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
	self.armature:removeBone(particles_bone, true)
	self.bone_particles[particles_bone_name] = nil
end