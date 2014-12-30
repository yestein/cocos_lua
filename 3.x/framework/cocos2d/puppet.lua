--=======================================================================
-- File Name    : puppet.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/24 13:34:03
-- Description  : base display element in screen
-- Modify       : 
--=======================================================================
if not Puppet then
	Puppet = Class:New(nil, "PUPPET")
end

function NewPuppet(name, orgin_direction)
	local puppet = Class:New(Puppet, Puppet:GetClassName().. "_" ..name)
	puppet:Init(name, orgin_direction)
	return puppet
end

function Puppet:_Uninit( ... )
	self.scale            = nil
	self.change_pos_child = nil
	self.child_list       = nil
	self.logic_direction  = nil
	self.orgin_direction  = nil
	self.main_sprite      = nil
	self.name             = nil

	return 1
end

function Puppet:_Init(name, orgin_direction)
	self.name = name
	self.main_sprite = nil
	self.orgin_direction = orgin_direction
	self.logic_direction = orgin_direction
	self.child_list = {}	
	self.change_pos_child = {}
	self.scale = 1

	return 1
end

function Puppet:GetScale()
	return self.scale
end

function Puppet:SetScale(scale_rate, during_time)
	self.scale = scale_rate
	local sprite = self.main_sprite
	if during_time then
		local scale_action = cc.ScaleTo:create(during_time, self.scale)
		scale_action:setTag(Def.TAG_SCALE_ACTION)
		sprite:runAction(scale_action)
	else
		sprite:setScale(self.scale)
	end
end

function Puppet:SetSprite(sprite)
	self.main_sprite = sprite
	self.bounding_box = sprite:getBoundingBox()
end

function Puppet:GetSprite()
	return self.main_sprite
end

function Puppet:GetBoundingBox()
	return self.bounding_box
end

function Puppet:SetAnchorPoint(anchor_point)
	self.main_sprite:setAnchorPoint(anchor_point)
end

function Puppet:SetPosition(x, y)
	self.main_sprite:setPosition(x, y)
end

function Puppet:GetPosition()
	return self.main_sprite:getPosition()
end

function Puppet:SetLocalZOrder(order)
	self.main_sprite:setLocalZOrder(order)
end

function Puppet:AddChildElement(name, child, x, y, is_change_position)
	local index = 1
	local child_name = name
	if self.child_list[child_name] then
		self.child_list[child_name].ref = self.child_list[child_name].ref + 1
		return
	end
	self.child_list[child_name] = {obj = child, ref = 1}
	self.main_sprite:addChild(child)
	if is_change_position == 1 then
		self.change_pos_child[child_name] = 1
	end
	local offset = {x = 0, y = 0}
	if self.main_sprite.getOffsetPoints then
		offset = self.main_sprite:getOffsetPoints()
	end
	local anchor_points = self.main_sprite:getAnchorPointInPoints()
	child:setPosition(x - offset.x + anchor_points.x, y - offset.y + anchor_points.y)
	return child_name
end

function Puppet:GetChildElement(name)
	if self.child_list[name] then
		return self.child_list[name].obj
	end
end

function Puppet:SetChildPosition(name, x, y)
	local child = self:GetChildElement(name)
	local offset = {x = 0, y = 0}
	if self.main_sprite.getOffsetPoints then
		offset = self.main_sprite:getOffsetPoints()
	end
	local anchor_points = self.main_sprite:getAnchorPointInPoints()
	child:setPosition(x - offset.x + anchor_points.x, y - offset.y + anchor_points.y)
end

function Puppet:RemoveChildElement(name)
	if not self.child_list[name] then
		assert(false, "No Child[%s]", name)
		return
	end
	self.child_list[name].ref = self.child_list[name].ref - 1
	if self.child_list[name].ref <= 0 then
		self.main_sprite:removeChild(self.child_list[name].obj, true)
		self.child_list[name] = nil
		if self.change_pos_child[name] then
			self.change_pos_child[name] = nil
		end
	end
end

function Puppet:GetDirection()
	return self.direction
end

function Puppet:GetLogicDirection()
	return self.logic_direction
end

function Puppet:SetDirection(direction)
	if direction == self.logic_direction then
		return
	end
	if direction == self.orgin_direction then
		self.direction = 1
	else
		self.direction = -1
	end
	local old_scale_x = self.main_sprite:getScaleX()
	self.main_sprite:setScaleX(-old_scale_x)
	self.logic_direction = direction
	for child_name, _ in pairs(self.change_pos_child) do
		local child_info = self.child_list[child_name]
		local child = child_info.obj
		local old_scale_x = child:getScaleX()
		child:setScaleX(-old_scale_x)
		local x, y = child:getPosition()
		child:setPosition(self.bounding_box.width - x, y)
	end
end

function Puppet:Pause()
	self.main_sprite:pause()
	for name, child in pairs(self.child_list) do
		child.obj:pause()
	end
end

function Puppet:Resume()
	self.main_sprite:resume()
	for _, child in pairs(self.child_list) do
		child.obj:resume()
	end
end