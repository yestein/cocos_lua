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

function MoveNode:Uninit()
	self.x         = nil
	self.y         = nil	
	self.speed     = nil

	self.next_pos   = nil
	self.target_pos = nil
end

function MoveNode:Init(x, y, speed)
	self.x           = x
	self.y           = y
	self.speed       = speed
	self.cur_speed_x = 0
	self.cur_speed_y = 0
	self.is_run      = 0

	self.next_pos   = {x = -1, y = -1}
	self.target_pos = {x = -1, y = -1}
end

function MoveNode:OnActive(frame)
	if self:IsArriveTarget() == 1 then
		return
	end
	if self:IsHaveNextPos() ~= 1 then
		return
	end
	if frame % 5 == 0 then
		self:MoveTo(self.next_pos.x, self.next_pos.y)
		if self:IsArriveTarget() == 1 then
			self:Stop()
		else
			self:GenerateNextPos()
		end
	end
end

function MoveNode:IsRun()
	return self.is_run
end

function MoveNode:Stop()
	self.target_pos.x = -1
	self.target_pos.y = -1
	self.next_pos.x   = -1
	self.next_pos.y   = -1
	self.cur_speed_x  = 0
	self.cur_speed_y  = 0
	self.is_run       = 0
	self:GetParent():SetActionState("normal")
	local event_name = self:GetParent():GetNodeName()..".STOP"
	Event:FireEvent(event_name, self:GetParent():GetId())
end

function MoveNode:MoveTo(x, y)
	x = math.floor(x)
	y = math.floor(y)
	local event_name = self:GetParent():GetNodeName()..".MOVETO"
	Event:FireEvent(event_name, self:GetParent():GetId(), x, y)
	local old_speed_x = self.cur_speed_x
	local old_speed_y = self.cur_speed_y
	self.cur_speed_x = x - self.x
	self.cur_speed_y = y - self.y

	if old_speed_x == 0 and old_speed_y == 0 then
		self.is_run = 1
		self:GetParent():SetActionState("run")
		local event_name = self:GetParent():GetNodeName()..".RUN"
		Event:FireEvent(event_name, self:GetParent():GetId())
	end
	if self.cur_speed_x > 0 then
		self:GetParent():SetDirection("right")
	else
		self:GetParent():SetDirection("left")
	end
	self.x = x
	self.y = y
end

function MoveNode:GoTo(x, y)
	x = math.floor(x)
	y = math.floor(y)
	local owner = self:GetParent()
	if owner:GetActionState() ~= "normal" then
		owner:InsertCommand({"GoTo", x, y}, 1)
		return
	end
	if self.x == x and self.y == y then
		return
	end
	local event_name = owner:GetNodeName()..".GOTO"
	Event:FireEvent(event_name, owner:GetId(), x, y)
	self.target_pos.x = x
	self.target_pos.y = y
	self:GenerateNextPos()
	--self:MoveTo(self.next_pos.x, self.next_pos.y)
	--self:GenerateNextPos()
end

function MoveNode:GenerateNextPos()
	if self:IsHaveTarget() ~= 1 then
		return
	end
	local distance = Lib:GetDistance(self.x, self.y, self.target_pos.x, self.target_pos.y)
	if distance <= self.speed then
		self.next_pos.x = self.target_pos.x
		self.next_pos.y = self.target_pos.y
		return
	end
	local rate = self.speed / distance
	local offset_x = math.ceil((self.target_pos.x - self.x) * rate)
	local offset_y = math.ceil((self.target_pos.y - self.y) * rate)

	self.next_pos.x = self.x + offset_x
	self.next_pos.y = self.y + offset_y
end

function MoveNode:MoveByDirection(direction)
	self:SetDirection(direction)
	local offset_x, offset_y = unpack(move_offset[direction])

	self:MoveTo(self.x + (offset_x * self.speed), self.y + (offset_y * self.speed))
end

function MoveNode:TransportTo(x, y)
	self.x = x
	self.y = y
	local event_name = self:GetParent():GetNodeName()..".TRANSPORT"
	Event:FireEvent(event_name, self:GetParent():GetId(), x, y)
end

function MoveNode:GetPosition()
	return self.x, self.y
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
	if self.x ~= self.target_pos.x or self.y ~= self.target_pos.y then
		return 0
	end
	return 1
end