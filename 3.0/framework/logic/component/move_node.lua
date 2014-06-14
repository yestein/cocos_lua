--=======================================================================
-- File Name    : move_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 14:20:03
-- Description  : make obj can move
-- Modify       : 
--=======================================================================

if not MoveNode then
	MoveNode = NewLogicNode("MOVE")
end

MoveNode.interval = 0.1

local move_offset = {
	left       = {-1, 0}, 
	right      = {1, 0},  
	up         = {0, 1},  
	down       = {0, -1}, 
	left_up    = {-1, 1}, 
	right_up   = {1, 1},  
	left_down  = {-1, -1},
	right_down = {1, -1}, 
}

function MoveNode:_Uninit()
	self.position  = nil
	self.speed     = nil

	self.next_pos   = nil
	self.target_pos = nil
end

function MoveNode:_Init(position, speed)
	self.position    = position
	self.speed       = speed
	self.cur_speed_x = 0
	self.cur_speed_y = 0
	self.interval_frame = math.floor(self.interval * GameMgr:GetFPS())

	self.next_pos   = {x = -1, y = -1}
	self.target_pos = {x = -1, y = -1}
	return 1
end

function MoveNode:OnActive(frame)
	if self:IsArriveTarget() == 1 then
		return
	end
	if self:IsHaveNextPos() ~= 1 then
		return
	end

	if (frame - self.move_frame) >= self.interval_frame then
		self:MoveTo(self.next_pos.x, self.next_pos.y)
		if self:IsArriveTarget() == 1 then
			self:Stop()
		else
			self:GenerateNextPos()
		end
	end
end

function MoveNode:Stop()
	self.target_pos.x = -1
	self.target_pos.y = -1
	self.next_pos.x   = -1
	self.next_pos.y   = -1
	self.cur_speed_x  = 0
	self.cur_speed_y  = 0
	self.move_frame = nil
	self:GetParent():TryCall("SetActionState", Def.STATE_NORMAL)
	local event_name = self:GetParent():GetClassName()..".STOP"
	Event:FireEvent(event_name, self:GetParent():GetId())
end

function MoveNode:MoveTo(x, y)
	x = math.floor(x)
	y = math.floor(y)
	local event_name = self:GetParent():GetClassName()..".MOVETO"
	Event:FireEvent(event_name, self:GetParent():GetId(), x, y)
	local old_speed_x = self.cur_speed_x
	local old_speed_y = self.cur_speed_y
	self.cur_speed_x = x - self.position.x
	self.cur_speed_y = y - self.position.y

	if old_speed_x == 0 and old_speed_y == 0 then
		self:GetParent():TryCall("SetActionState", Def.STATE_RUN)
		local event_name = self:GetParent():GetClassName()..".RUN"
		Event:FireEvent(event_name, self:GetParent():GetId())
	end
	if self.cur_speed_x > 0 then
		self:GetParent():SetDirection("right")
	elseif self.cur_speed_x < 0 then
		self:GetParent():SetDirection("left")
	end
	self.position.x = x
	self.position.y = y
	self.move_frame = GameMgr:GetCurrentFrame()
end

function MoveNode:GoTo(x, y)
	x = math.floor(x)
	y = math.floor(y)
	local owner = self:GetParent()
	if self.position.x == x and self.position.y == y then
		return
	end
	local event_name = owner:GetClassName()..".GOTO"
	Event:FireEvent(event_name, owner:GetId(), x, y)
	self.target_pos.x = x
	self.target_pos.y = y
	self:GenerateNextPos()
	if not self.move_frame then
		self:MoveTo(self.next_pos.x, self.next_pos.y)
		self:GenerateNextPos()
	end
end

function MoveNode:GenerateNextPos()
	if self:IsHaveTarget() ~= 1 then
		return
	end
	local x, y = self.position.x, self.position.y
	local distance = Lib:GetDistance(x, y, self.target_pos.x, self.target_pos.y)
	if distance <= self.speed then
		self.next_pos.x = self.target_pos.x
		self.next_pos.y = self.target_pos.y
		return
	end
	local rate = self.speed / distance
	local offset_x = math.ceil((self.target_pos.x - x) * rate)
	local offset_y = math.ceil((self.target_pos.y - y) * rate)

	self.next_pos.x = x + offset_x
	self.next_pos.y = y + offset_y
end

function MoveNode:MoveByDirection(direction)
	self:SetDirection(direction)
	local offset_x, offset_y = unpack(move_offset[direction])

	self:MoveTo(self.position.x + (offset_x * self.speed), self.position.y + (offset_y * self.speed))
end

function MoveNode:TransportTo(x, y)
	self.position.x = x
	self.position.y = y
	local event_name = self:GetParent():GetClassName()..".TRANSPORT"
	Event:FireEvent(event_name, self:GetParent():GetId(), x, y)
end

function MoveNode:GetPosition()
	return self:GetParent():GetPosition()
end

function MoveNode:GetSpeed()
	return self.speed
end

function MoveNode:GetCurSpeed()
	return self.cur_speed_x, self.cur_speed_y
end

function MoveNode:IsHaveTarget()
	if self.target_pos.x < 0 or self.target_pos.y < 0 then
		return 0
	end
	return 1
end

function MoveNode:IsHaveNextPos()
	if self.next_pos.x < 0 or self.next_pos.y < 0 then
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