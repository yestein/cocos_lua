--=======================================================================
-- File Name    : spine_skelton.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/7/29 14:11:00
-- Description  : description
-- Modify       :
--=======================================================================

if not SpineSkelton then
    SpineSkelton = Class:New(Puppet, "SPINE_SKELTON")
    SpineSkelton.default_animation_name = {}
    SpineSkelton.animation_name = {}
    SpineSkelton.animation_next = {}
end

function SpineSkelton:SetDefaultAnimationName(animation_name, resource_name)
    self.default_animation_name[animation_name] = resource_name
end

function SpineSkelton:SetSkeltonAnimationName(skelton_name, animation_name, resource_name)
    if not self.animation_name[skelton_name] then
        self.animation_name[skelton_name] = {}
    end
    self.animation_name[skelton_name][animation_name] = resource_name
end

function SpineSkelton:GetSkeltonAnimationName(skelton_name, animation_name)
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

function NewSpineSkelton(skelton_name, orgin_direction, param)
    if not skelton_name then
        assert(false, "skelton_name is nil")
        return
    end
    local skelton = Class:New(SpineSkelton)
    if skelton:Init(skelton_name, orgin_direction, param) ~= 1 then
        return
    end
    return skelton
end

function SpineSkelton:_Uninit()

    self.draw_node = nil
    self.animation_func    = nil
    self.animation_speed   = nil
    self.frame_func        = nil
    self.current_animation = nil
    self.bone_diplay_index = nil
    self.bone_diplay_name  = nil
    self.skelton_name      = nil

    return 1
end

function SpineSkelton:_Init(name, orgin_direction, param)
    self.is_debug_boundingbox = param.is_debug_boundingbox
    self.animation_speed = {}
    self.event_func = {}
    self.draw_node = nil

    local sprite = cc.Sprite:create()
    sprite:setAnchorPoint(cc.p(0.5, 0))
    self:SetSprite(sprite)

    if not self:SetArmature(name, orgin_direction, param) then
        return 0
    end
    self:PlayAnimation("normal", -1)
    self:SetMix("normal", "run", 0.1)
    self:SetMix("run", "attack", 0.1)
    self:SetMix("attack", "hit", 0.1)
    self:SetMix("attack", "dead", 0.1)
    self:SetMix("hit", "normal", 0.1)
    self:SetMix("cheer", "normal", 0.1)

    if self:IsDebugBoundingBox() == 1 then
        self:AddDebugSkelton()
    end
    return 1
end

function SpineSkelton:SetMix(ani_1, ani_2, time)
    local name_1 = self:GetAnimationResourceName(ani_1)
    local name_2 = self:GetAnimationResourceName(ani_2)

    self:GetArmature():setMix(name_1, name_2, time)
end

function SpineSkelton:SetArmature(skelton_name, orgin_direction, param)
    local sp_skelton = Resource:LoadSpine(skelton_name)
    if not sp_skelton then
        return
    end
    local sprite = self:GetSprite()
    self.skelton_name = skelton_name
    self.bone_diplay_name = {}
    self.bone_diplay_index = {}
    self.orgin_direction = orgin_direction

    if param then
        local scale = 1
        if param.scale then
            scale = param.scale
        else
            local rect = sp_skelton:getBoundingBox()
            if param.width and param.height then
                local scale_width = param.width / rect.width
                local scale_height = param.height / rect.height
                scale = scale_width < scale_height and scale_width or scale_height
            elseif param.width then
                scale = param.width / rect.width
            elseif param.height then
                scale = param.height / rect.height
            end
        end
        sp_skelton:setScale(scale)
    end

    sp_skelton:registerSpineEventHandler(
        function(event)
            local event_name = event.animation
            local event_type = event.type
            if not self.event_func[event_type] then
                return
            end
            local func = self.event_func[event_type][event_name]
            if not func then
                return
            end
            func(event)
        end
    )
    self:AddChildElement("armature", sp_skelton, 0, 0, 1, 10)

    if param then
        if param.skin then
            sp_skelton:setSkin(param.skin)
        end

        if param.shader_name then
            local shader = ShaderMgr:GetShader(param.shader_name)
            assert(shader)
            if shader then
                sp_skelton:setGLProgram(shader)
            end
        end

        if param.animation_speed then
            for k, v in pairs(param.animation_speed) do
                self:SetAnimationSpeed(k, v)
            end
        end
    end

    sp_skelton:update(0)
    local rect = sp_skelton:getBoundingBox()
    sprite:setContentSize({width = rect.width, height = rect.height})
    self:SetSprite(sprite)
    sp_skelton:setPositionX(rect.width / 2)


    return sp_skelton
end

function SpineSkelton:GetArmature()
    return self:GetChildElement("armature")
end

function SpineSkelton:RegistAnimationEvent(call_back)
    local sp_skelton = self:GetChildElement("armature")
    if not sp_skelton then
        assert(false, "[RegistAnimationEvent] Not Found SpineSkelton!")
        return
    end
    return sp_skelton:registerSpineEventHandler(call_back)
end

function SpineSkelton:SetAnimationSpeed(animation_name, speed_scale)
    self.animation_speed[animation_name] = speed_scale
    if self:GetCurrentAnimation() == animation_name then
        self:GetArmature():setTimeScale(speed_scale)
    end
end

function SpineSkelton:GetAnimationSpeed(animation_name)
    return self.animation_speed[animation_name] or 1
end

function SpineSkelton:GetAnimationResourceName(skelton_name, animation_name)
    local resource_name = self:GetSkeltonAnimationName(skelton_name, animation_name)
    if type(resource_name) == "string" then
        return resource_name
    elseif type(resource_name) == "table" then
        if self.animation_next[skelton_name] then
            return resource_name[1]
        else
            local random_index = DisplayRandom:Get(1, #resource_name)
            return resource_name[random_index]
        end
    end
end

function SpineSkelton:PlayAnimation(animation_name, is_loop)
    if is_loop == -1 then
        is_loop = true
    elseif is_loop == 0 then
        is_loop = false
    end
    local resource_name = self:GetAnimationResourceName(self.skelton_name, animation_name)
    if not resource_name then
        log_print(string.format("No Animation[%s]", animation_name))
        return
    end
    local sp_skelton = self:GetArmature()
    local speed_scale = self:GetAnimationSpeed(animation_name)
    if speed_scale then
        sp_skelton:setTimeScale(speed_scale)
    end
    sp_skelton:setToSetupPose()
    sp_skelton:setAnimation(0, resource_name, is_loop)

    self.current_animation = animation_name
end

function SpineSkelton:AddAnimation(animation_name, is_loop)
    if is_loop == -1 then
        is_loop = true
    elseif is_loop == 0 then
        is_loop = false
    end
    local resource_name = self:GetAnimationResourceName(self.skelton_name, animation_name)
    if not resource_name then
        log_print(string.format("No Animation[%s]", animation_name))
        return
    end
    local sp_skelton = self:GetArmature()
    local speed_scale = self:GetAnimationSpeed(animation_name)
    if speed_scale then
        sp_skelton:setTimeScale(speed_scale)
    end
    sp_skelton:setToSetupPose()
    sp_skelton:addAnimation(0, resource_name, is_loop)

    self.current_animation = animation_name
end

function SpineSkelton:PlayRawAnimation(track_index, resource_name, is_loop)
    local sp_skelton = self:GetArmature()
    sp_skelton:setToSetupPose()
    return sp_skelton:addAnimation(track_index, resource_name, is_loop)
end

function SpineSkelton:GetCurrentAnimation()
    return self.current_animation
end

function SpineSkelton:SetAnimationFunc(movement_type, animation_name, func)
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

function SpineSkelton:SetMoveMentFunc(movement_type, movement_id, func)
    if not self.event_func[movement_type] then
        self.event_func[movement_type] = {}
    end
    self.event_func[movement_type][movement_id] = func
end

function SpineSkelton:SetFrameFunc(event_name, func)
    return
end

function SpineSkelton:MoveTo(target_x, target_y, during_time, call_back)
    local cc_sprite = self:GetSprite()
    local x, y = cc_sprite:getPosition()
    local animation_name = "run"
    if self:GetCurrentAnimation() ~= animation_name then
        self:PlayAnimation(animation_name, -1)
    end
    local action_list = {}
    action_list[#action_list + 1] = cc.MoveBy:create(during_time, cc.p(target_x - x, target_y - y))
    if call_back then
        action_list[#action_list + 1] = cc.CallFunc:create(call_back)
    end
    local sequece_action = cc.Sequence:create(unpack(action_list))
    sequece_action:setTag(Def.TAG_MOVE_ACTION)
    cc_sprite:stopActionByTag(Def.TAG_MOVE_ACTION)
    cc_sprite:runAction(sequece_action)
end

function SpineSkelton:StopMove()
    self:GetSprite():stopActionByTag(Def.TAG_MOVE_ACTION)
    self:PlayAnimation("normal", -1)
end

function SpineSkelton:AddDebugSkelton()
    local draw_node = cc.DrawNode:create()
    draw_node:drawDot(cc.p(0, 0), 5, cc.c4b(0, 0, 1, 1))
    self:GetArmature():addChild(draw_node, 10000)
    self.draw_node = draw_node
end

function SpineSkelton:RemoveDebugSkelton()
    self:GetArmature():removeChild(self.draw_node, true)
    self.draw_node = nil
end

function SpineSkelton:IsDebugBoundingBox()
    return self.is_debug_boundingbox
end

function SpineSkelton:ReplaceArmature(skelton_name, orgin_direction, param)
    self:RemoveChildElement("armature")
    local old_skelton_name = self.skelton_name

    if not self:SetArmature(skelton_name, orgin_direction, param) then
        return 0
    end

    self:SetDirection(self.logic_direction)
    self:PlayAnimation("normal", -1)
    Event:FireEvent("SKELTON.REPLACE", old_skelton_name, self.skelton_name)
    return 1
end

function SpineSkelton:SetShader(shader_name, uniform_list)
    local sp_skelton = self:GetArmature()
    ShaderMgr:AttachShader(sp_skelton, shader_name, uniform_list)
end

function SpineSkelton:RestoreShader()
    local state = cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor"))
    local sp_skelton = self:GetArmature()
    sp_skelton:setGLProgramState(state)
end


function SpineSkelton:Pause()
    self.main_sprite:pause()
    for name, child in pairs(self.child_list) do
        child.obj:pause()
    end

end

function SpineSkelton:Resume()
    self.main_sprite:resume()
    for name, child in pairs(self.child_list) do
        child.obj:resume()
    end
end
