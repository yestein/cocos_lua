--=======================================================================
-- File Name    : bullet_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/30 15:30:46
-- Description  : make a obj to be a bullet
-- Modify       : 
--=======================================================================

local BulletNode = ComponentMgr:GetComponent("BULLET")
if not BulletNode then
	BulletNode = ComponentMgr:CreateComponent("BULLET")
end

BulletNode.MAX_SPEED = 300

function BulletNode:_Uninit()
	self.position  = nil
	self.speed     = nil

	self.next_pos   = nil
	self.target_pos = nil

	return 1
end

function BulletNode:_Init(position, speed)
	self.position    = position
	self.speed       = speed
	if self.speed > self.MAX_SPEED then
		self.speed = self.MAX_SPEED
	end
	self.cur_speed_x = 0
	self.cur_speed_y = 0

	self.next_pos   = {x = nil, y = nil}
	self.target_pos = {x = nil, y = nil}
	return 1
end

function BulletNode:OnLoop()
	if self:IsArriveTarget() == 1 then
		return
	end
	self:MoveToTarget()
end

function BulletNode:Stop()
	self.target_pos.x = nil
	self.target_pos.y = nil
	self.next_pos.x   = nil
	self.next_pos.y   = nil
	self.cur_speed_x  = 0
	self.cur_speed_y  = 0
end

function BulletNode:MoveTo(x, y)
	x = math.floor(x)
	y = math.floor(y)
	local owner = self:GetParent()
	local can_move = 1
	if can_move == 1 then
		local event_name = owner:GetClassName()..".MOVETO"
		Event:FireEvent(event_name, self:GetParent():GetId(), x, y)
		local old_speed_x = self.cur_speed_x
		local old_speed_y = self.cur_speed_y
		self.cur_speed_x = x - self.position.x
		self.cur_speed_y = y - self.position.y
		if self.cur_speed_x > 0 then
			self:GetParent():TryCall("SetDirection", "right")
		elseif self.cur_speed_x < 0 then
			self:GetParent():TryCall("SetDirection", "left")
		end
		self.position.x = x
		self.position.y = y
	else
		self.cur_speed_x = 0
		self.cur_speed_y = 0
	end
end

function BulletNode:GoTo(x, y, call_back)
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
	self.call_back = call_back
end

function BulletNode:MoveToTarget()
	self:MoveTo(self.next_pos.x, self.next_pos.y)
	if self:IsArriveTarget() == 1 then
		self:Stop()
		if self.call_back then
			Lib:SafeCall(self.call_back)
		end
	else
		self:GenerateNextPos()
	end
end

function BulletNode:GenerateNextPos()
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

function BulletNode:GetPosition()
	return self:GetParent():GetPosition()
end

function BulletNode:GetMoveSpeed()
	return self.speed
end

function BulletNode:SetMoveSpeed(speed)
	local old_speed = self.speed
	self.speed = speed
	if self.speed > self.MAX_SPEED then
		self.speed = self.MAX_SPEED
	end
	local event_name = self:GetParent():GetClassName()..".SET_MOVE_SPEED"
	Event:FireEvent(event_name, self:GetParent():GetId(), self.speed, old_speed)
end

function BulletNode:GetCurSpeed()
	return self.cur_speed_x, self.cur_speed_y
end

function BulletNode:IsHaveTarget()
	if not self.target_pos.x or not self.target_pos.y then
		return 0
	end
	return 1
end

function BulletNode:IsHaveNextPos()
	if not self.next_pos.x or not self.next_pos.y then
		return 0
	end
	return 1
end

function BulletNode:IsArriveTarget()
	if self:IsHaveTarget() ~= 1 then
		return 1
	end
	if self.position.x ~= self.target_pos.x or self.position.y ~= self.target_pos.y then
		return 0
	end
	return 1
end

function BulletNode:SetMaxSpeed(max_speed)
	self.MAX_SPEED = max_speed
end