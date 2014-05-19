--=======================================================================
-- File Name    : move_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 14:20:03
-- Description  : make obj can move
-- Modify       : 
--=======================================================================

if not MoveNode then
	MoveNode = Lib:NewClass(LogicNode)
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
	self.direction = nil

	self.next_pos   = nil
	self.target_pos = nil
end

function MoveNode:Init(x, y, direction, speed)
	self.x         = x
	self.y         = y
	self.direction = direction
	self.speed     = speed

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
	if frame % 10 == 0 then
		self:MoveTo(self.next_pos.x, self.next_pos.y)
		if self:IsArriveTarget() == 1 then
			self.target_pos.x = -1
			self.target_pos.y = -1
			self.next_pos.x = -1
			self.next_pos.y = -1
		else
			self:GenerateNextPos()
		end
	end
end

function MoveNode:MoveTo(x, y)
	local event_name = self:GetParent():GetNodeName()..".MOVETO"
	Event:FireEvent(event_name, self:GetParent():GetId(), self.x, self.y, x, y)
	self.x = x
	self.y = y
end

function MoveNode:GoTo(x, y)
	if self.x == x and self.y == y then
		return
	end
	local event_name = self:GetParent():GetNodeName()..".GOTO"
	Event:FireEvent(event_name, self:GetParent():GetId(), self.x, self.y, x, y)
	self.target_pos.x = x
	self.target_pos.y = y
	if self.target_pos.x > self.x then
		self:SetDirection("right")
	else
		self:SetDirection("left")
	end
	self:GenerateNextPos()
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

function MoveNode:SetDirection(direction)
	if self.direction ~= direction then
		self.direction = direction
		local event_name = self:GetParent():GetNodeName()..".CHANGE_DIRECTION"
		Event:FireEvent(event_name, self:GetParent():GetId(), direction)
	end
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

function MoveNode:GetDirection()
	return self.direction
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