--=======================================================================
-- File Name    : direction_move_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/7/31 14:34:46
-- Description  : description
-- Modify       :
--=======================================================================


local DirectionMoveNode = ComponentMgr:GetComponent("DIRECTION_MOVE")
if not DirectionMoveNode then
    DirectionMoveNode = ComponentMgr:CreateComponent("DIRECTION_MOVE")
end

DirectionMoveNode.MAX_SPEED = 1000
DirectionMoveNode:DeclareHandleMsg("MOVE", "Breath")
DirectionMoveNode:DeclareHandleMsg("OWNER_DEAD", "OnOwnerDead")

local move_offset = {
    left  = {-1, 0},
    right = {1, 0},
}

DirectionMoveNode.forbid_move_state = {}
function DirectionMoveNode:SetForbidState(key, value)
    self.forbid_move_state[key] = value
end

function DirectionMoveNode:_Uninit()
    self.target_x = nil
    self.target_y = nil

    self.move_direction = nil
    self.speed = nil
    self.position  = nil

    return 1
end

function DirectionMoveNode:_Init(position)
    self.position    = position
    self.speed       = 0
    self.move_direction = "none"

    self.default_move_speed = nil
    self.default_direction = nil

    self.target_x = nil
    self.target_y = nil
    return 1
end

function DirectionMoveNode:SetPosition(x, y)
    self.position.x = x
    self.position.y = y
end

function DirectionMoveNode:GetPosition()
    return self.position
end

function DirectionMoveNode:GetXY()
    return self.position.x, self.position.y
end

function DirectionMoveNode:GetMoveDirection()
    return self.move_direction
end

function DirectionMoveNode:SetMoveDirection(direction)
    local old_direction = self.move_direction
    self.move_direction = direction

    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".CHANGE_MOVE_DIRECTION"
    Event:FireEvent(event_name, owner:GetId(), direction, old_direction)
end

function DirectionMoveNode:SetDefaultMoveDirection(direction)
    self.default_move_direction = direction
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".SET_DEFAULT_MOVE_DIRECTION"
    Event:FireEvent(event_name, owner:GetId(), direction)
end

function DirectionMoveNode:SetDefaultMoveSpeed(speed)
    self.default_move_speed = speed
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".SET_DEFAULT_MOVE_SPEED"
    Event:FireEvent(event_name, owner:GetId(), speed)
end

function DirectionMoveNode:GetMoveSpeed()
    return self.speed * GameMgr:GetFPS()
end

--传入速度单位为“像素/秒”，实际系统内部用速度为“像素/帧”，但暴露给外界的速度统一为“像素/秒”
function DirectionMoveNode:SetMoveSpeed(speed)
    if speed > self.MAX_SPEED then
        speed = self.MAX_SPEED
    end
    local fps = GameMgr:GetFPS()
    local old_speed = self:GetMoveSpeed()
    speed = speed - (speed % fps)
    self.speed = math.floor(speed / fps)
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".SET_MOVE_SPEED"
    Event:FireEvent(event_name, owner:GetId(), speed, old_speed)
end

function DirectionMoveNode:GetTarget()
    return self.target_x, self.target_y
end

function DirectionMoveNode:SetTarget(x, y)
    self.target_x = x
    self.target_y = y

    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".SET_MOVE_TARGET"
    Event:FireEvent(event_name, owner:GetId(), x, y)
end

function DirectionMoveNode:StopMove()
    self.move_direction = "none"
    self:SetTarget(nil, nil)
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".STOP"
    Event:FireEvent(event_name, owner:GetId())
end

function DirectionMoveNode:TransportTo(x, y)
    self:StopMove()
    local old_x, old_y = self.position.x, self.position.y
    self:SetPosition(x, y)
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".TRANSPORT"
    Event:FireEvent(event_name, owner:GetId(), x, y, old_x, old_y)

end

function DirectionMoveNode:SetMaxSpeed(max_speed)
    self.MAX_SPEED = max_speed
end

function DirectionMoveNode:Breath(frame)
    if self.move_direction == "none" then
        return
    end

    if self.speed == 0 then
        return
    end

    local owner = self:GetParent()
    for state, _ in pairs(self.forbid_move_state) do
        if owner:TryCall("GetBuffState", state) then
            return
        end
    end

    return self:_Move()
end

function DirectionMoveNode:_Move()
    local offset_x, offset_y = unpack(move_offset[self.move_direction])
    local move_x, move_y = offset_x * self.speed, offset_y * self.speed
    local x, y = self:GetXY()

    local final_x, final_y = x + move_x, y + move_y
    local target_x, target_y = self:GetTarget()

    if self:_IsArriveTarget(final_x, final_y, move_x, move_y, target_x, target_y) == 1 then
        final_x = target_x
        final_y = target_y
        self:StopMove()
        local owner = self:GetParent()
        local event_name = owner:GetClassName()..".ARRIVED_TARGET"
        Event:FireEvent(event_name, owner:GetId(), target_x, target_y)
    end
    self:SetPosition(final_x, final_y)
    if final_x ~= x then
        local owner = self:GetParent()
        local event_name = owner:GetClassName()..".MOVE"
        local direction = self.move_direction
        local move_speed = self:GetMoveSpeed()
        Event:FireEvent(event_name, owner:GetId(), direction, move_speed, final_x)
    end
end

function DirectionMoveNode:DefaultMove()
    if not self.default_move_direction or not self.default_move_speed then
        return
    end
    self:SetMoveDirection(self.default_move_direction)
    self:SetMoveSpeed(self.default_move_speed)
end

function DirectionMoveNode:OnOwnerDead()
    self:StopMove()
end


--TODO 这里暂时只为1维轴游戏服务
function DirectionMoveNode:_IsArriveTarget(final_x, final_y, move_x, move_y, target_x, target_y)
    if not target_x or not target_y then
        return 0
    end

    if (move_x > 0 and final_x < target_x) or (move_x < 0 and target_x < final_x ) then
        return 0
    end

    return 1
end

function DirectionMoveNode:_IsMoveToBorder(final_x)

    if final_x < 0 or final_x > visible_size.width  then
        return true
    end

    return false
end
