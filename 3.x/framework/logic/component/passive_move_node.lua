--=======================================================================
-- File Name    : passsive_move_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 14:20:03
-- Description  : make obj can move (direct by display)
-- Modify       : 
--=======================================================================

local MoveNode = ComponentMgr:GetComponent("PASSIVE_MOVE")
if not MoveNode then
	MoveNode = ComponentMgr:CreateComponent("PASSIVE_MOVE")
end

MoveNode.MAX_SPEED = 2000

local forbid_move_state = {
	[Def.BUFF_SLEEP ]   = 1,
	[Def.BUFF_STUN  ]   = 1,
	[Def.BUFF_FREEZE]   = 1,
}

function MoveNode:_Uninit()
	self.sprite        = nil
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method   = nil
	
	self.target_pos    = nil
	self.cur_speed     = nil
	self.speed         = nil
	

	return 1
end

function MoveNode:_Init(position, speed)
	self.position = position
	self.speed = speed
	if self.speed > self.MAX_SPEED then
		self.speed = self.MAX_SPEED
	end
	self.cur_speed = 0

	self.target_pos = {x = nil, y = nil}
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method   = nil
	return 1
end

function MoveNode:StopMove()
	self.target_pos.x = nil
	self.target_pos.y = nil

	self.cur_speed  = 0
end

function MoveNode:GoTo(x, y, call_back)
	x = math.floor(x)
	y = math.floor(y)
	local owner = self:GetParent()
	local position = self:GetPosition()
	
	if equal(position.x, x) and equal(position.y, y) then
		return "目的地原地"
	end	
	
	local buff_node = owner:GetChild("buff")
	if buff_node then
		local can_move = 1
		for state, _ in pairs(forbid_move_state) do
			if owner:TryCall("GetBuffState", state) then
				can_move = 0
				break
			end
		end
		if can_move == 0 then
			return "无法移动"
		end
	end
	

	if owner:TryCall("SetActionState", Def.STATE_RUN) == 0 then
		return "状态错误"
	end

	local event_name = owner:GetClassName()..".PASSIVE_GOTO"
	Event:FireEvent(event_name, owner:GetId(), x, y)
	self.cur_speed = self.speed
	self.target_pos.x = x
	self.target_pos.y = y
	self.call_back = call_back
end

function MoveNode:Stop()
	local owner = self:GetParent()
	if owner:TryCall("SetActionState", Def.STATE_NORMAL) ~= 1 then
		return 0
	end
	self:StopMove()
	local event_name = owner:GetClassName()..".STOP"
	Event:FireEvent(event_name, owner:GetId())
	return 1
end

function MoveNode:DirectMove(x, y, time)
	local owner = self:GetParent()
	if self:Stop() ~= 1 then
		return 0
	end
	if owner:TryCall("SetActionState", Def.STATE_MOVE) ~= 1 then
		return 0
	end	
	
	local event_name = owner:GetClassName()..".DIRECT_MOVE"
	Event:FireEvent(event_name, owner:GetId(), x, y, time)
	return 1
end

function MoveNode:TransportTo(x, y, time)
	self:StopMove()
	local owner = self:GetParent()
	local event_name = owner:GetClassName()..".TRANSPORT"
	Event:FireEvent(event_name, owner:GetId(), x, y, time)
end

function MoveNode:SetSprite(sprite)
	self.sprite = sprite
end

function MoveNode:GetPosition()
	if self.sprite then
		self.position.x, self.position.y = self.sprite:getPosition()
		return self.position
	end
	return self.position
end

function MoveNode:GetXY()
	if self.sprite then
		return self.sprite:getPosition()
	end
	return self.position.x, self.position.y
end

function MoveNode:GetMoveSpeed()
	return self.speed
end

function MoveNode:SetMoveSpeed(speed)
	local old_speed = self.speed
	self.speed = speed
	local owner = self:GetParent()
	local event_name = owner:GetClassName()..".SET_MOVE_SPEED"
	Event:FireEvent(event_name, owner:GetId(), speed, old_speed)
end

function MoveNode:GetCurSpeed()
	return self.cur_speed
end

function MoveNode:IsHaveTarget()
	if not self.target_pos.x or not self.target_pos.y then
		return 0
	end
	return 1
end

function MoveNode:GetMoveTarget()
	return self.target_pos
end


function MoveNode:IsArriveTarget()
	if self:IsHaveTarget() ~= 1 then
		return 0
	end
	local position = self:GetPosition()
	if not equal(position.x, self.target_pos.x) or not equal(position.y, self.target_pos.y) then
		return 0
	end
	return 1
end

function MoveNode:SetMaxSpeed(max_speed)
	self.MAX_SPEED = max_speed
end

function MoveNode:Jump(target_x, target_y, method)
	local owner = self:GetParent()
	local can_move = 1
	for state, _ in pairs(forbid_move_state) do
		if owner:TryCall("GetBuffState", state) then
			can_move = 0
			break
		end
	end
	local state = owner:TryCall("GetActionState")
	if state == Def.STATE_DEAD or state == Def.STATE_HIT then
		can_move = 0
	end
	if can_move ~= 1 then
		return 0
	end
	self:Stop()
	if owner:TryCall("SetActionState", Def.STATE_JUMP) ~= 1 then
		return 0
	end
	self.jump_target_x = target_x
	self.jump_target_y = target_y
	self.jump_method = method
	local event_name = owner:GetClassName()..".JUMP"
	Event:FireEvent(event_name, owner:GetId(), target_x, target_y, method)

	if method ~= Def.JUMP_WAIT then
		self:JumpToTarget()
	end
	return 1
end

function MoveNode:JumpToTarget()
	if not self.jump_target_x or not self.jump_target_y or not self.jump_method then
		return 0
	end
	local owner = self:GetParent()
	self:StopMove()
	local event_name = owner:GetClassName()..".JUMP_TO_TARGET"
	Event:FireEvent(event_name, owner:GetId(), self.jump_target_x, self.jump_target_y, self.jump_method)
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method = nil
	return 1
end