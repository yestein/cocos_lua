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

MoveNode.MAX_SPEED = 2000 * Def.MOVE_INTERVAL

local forbid_move_state = {
	[Def.BUFF_SLEEP ]   = 1,
	[Def.BUFF_STUN  ]   = 1,
	[Def.BUFF_FREEZE]   = 1,
}

function MoveNode:_Uninit()
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method   = nil
	self.position  = nil
	self.speed     = nil

	self.next_pos   = nil
	self.target_pos = nil

	return 1
end

function MoveNode:_Init(position, speed)
	self.position    = position
	self.speed       = speed
	if self.speed > self.MAX_SPEED then
		self.speed = self.MAX_SPEED
	end
	self.cur_speed_x = 0
	self.cur_speed_y = 0

	self.target_pos = {x = nil, y = nil}
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method   = nil
	return 1
end

function MoveNode:StopMove()
	self.target_pos.x = nil
	self.target_pos.y = nil

	self.cur_speed_x  = 0
	self.cur_speed_y  = 0
end

function MoveNode:GoTo(x, y, call_back)
	x = math.floor(x)
	y = math.floor(y)
	local owner = self:GetParent()
	if self.position.x == x and self.position.y == y then
		return
	end
	if owner:TryCall("SetActionState", Def.STATE_RUN) ~= 1 then
		return
	end
	local event_name = owner:GetClassName()..".PASSIVE_GOTO"
	Event:FireEvent(event_name, owner:GetId(), x, y)
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

function MoveNode:SyncMove(x, y)
	local fun = Stat:GetStatFunc("SyncMove")
	x = math.floor(x)
	y = math.floor(y)
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
	if can_move == 1 then
		Map:OnCharacterMove(owner:GetId(), x, y)
		local old_speed_x = self.cur_speed_x
		local old_speed_y = self.cur_speed_y
		self.cur_speed_x = x - self.position.x
		self.cur_speed_y = y - self.position.y

		if old_speed_x == 0 and old_speed_y == 0 then
			local event_name = owner:GetClassName()..".RUN"
			Event:FireEvent(event_name, owner:GetId())
		end
		if self.cur_speed_x > 0 then
			owner:SetDirection("right")
		elseif self.cur_speed_x < 0 then
			owner:SetDirection("left")
		end
		self.position.x = x
		self.position.y = y
	else
		self:Stop()
		self.cur_speed_x = 0
		self.cur_speed_y = 0
	end
	if fun then
		fun()
	end
	return 1
end

function MoveNode:DirectMove(x, y)
	local owner = self:GetParent()
	if owner:TryCall("SetActionState", Def.STATE_MOVE) ~= 1 then
		return 0
	end	
	self:StopMove()
	local event_name = owner:GetClassName()..".DIRECT_MOVE"
	Event:FireEvent(event_name, owner:GetId(), x, y)
	self.position.x = x
	self.position.y = y
	return 1
end

function MoveNode:TransportTo(x, y)
	self:StopMove()
	local owner = self:GetParent()
	local event_name = owner:GetClassName()..".TRANSPORT"
	Event:FireEvent(event_name, owner:GetId(), x, y)
	self.position.x = x
	self.position.y = y
end

function MoveNode:GetPosition()
	return self.position
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
	return self.cur_speed_x, self.cur_speed_y
end

function MoveNode:IsHaveTarget()
	if not self.target_pos.x or not self.target_pos.y then
		return 0
	end
	return 1
end

function MoveNode:IsArriveTarget()
	if self:IsHaveTarget() ~= 1 then
		return 0
	end
	if self.position.x ~= self.target_pos.x or self.position.y ~= self.target_pos.y then
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
	if owner:TryCall("SetActionState", Def.STATE_JUMP) ~= 1 then
		return 0
	end
	self:StopMove()
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
	self.position.x = self.jump_target_x
	self.position.y = self.jump_target_y
	self.jump_target_x = nil
	self.jump_target_y = nil
	self.jump_method = nil
	return 1
end