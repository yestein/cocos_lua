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

function Puppet:_Uninit( ... )
	self.change_pos_child = nil
	self.child_list       = nil		
	self.orgin_direction  = nil
	self.sprite           = nil
	self.name             = nil

	return 1
end

function Puppet:_Init(name, orgin_direction)
	self.name = name
	self.sprite = cc.Sprite:create()
	self.orgin_direction = orgin_direction
	self.direction = 1
	self.logic_direction = orgin_direction or "left"
	self.child_list = {}	
	self.change_pos_child = {}
	self.scale = 1

	return 1
end

function NewPuppet(name, orgin_direction)
	local puppet = Class:New(Puppet, Puppet:GetClassName().. "_" ..name)
	puppet:Init(name, orgin_direction)
	return puppet
end

function Puppet:GetScale()
	return self.scale
end

function Puppet:SetScale(scale_rate, during_time)
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

function Puppet:GetSprite()
	return self.sprite
end

function Puppet:SetAnchorPoint(anchor_point)
	self.sprite:setAnchorPoint(anchor_point)
end

function Puppet:SetPosition(x, y)
	self.sprite:setPosition(x, y)
end

function Puppet:SetLocalZOrder(order)
	self.sprite:setLocalZOrder(order)
end

function Puppet:AddChildElement(name, child, x, y, is_change_position, z_order)
	local index = 1
	local child_name = name
	if self.child_list[child_name] then
		self.child_list[child_name].ref = self.child_list[child_name].ref + 1
		return
	end
	if not x or not y then
		x, y = 0, 0
	end
	if is_change_position then
		child:setPosition(x * self.direction, y)
	else
		child:setPosition(x, y)
	end
	self.child_list[child_name] = {obj = child, raw_x = x, ref = 1}
	if not z_order then
		child:setLocalZOrder(10)
	else
		child:setLocalZOrder(z_order)
	end
	self.sprite:addChild(child)
	if is_change_position == 1 then
		self.change_pos_child[child_name] = 1
	end
	return child_name
end

function Puppet:GetChildElement(name)
	if self.child_list[name] then
		return self.child_list[name].obj
	end
end

function Puppet:RemoveChildElement(name)
	if not self.child_list[name] then
		assert(false, "No Child[%s]", name)
		return
	end
	self.child_list[name].ref = self.child_list[name].ref - 1
	if self.child_list[name].ref <= 0 then
		self.sprite:removeChild(self.child_list[name].obj, true)
		self.child_list[name] = nil
		if self.change_pos_child[name] then
			self.change_pos_child[name] = nil
		end
	end
end

function Puppet:GetDirection()
	return self.direction
end

function Puppet:SetDirection(direction)
	if direction == self.orgin_direction then
		self.direction = 1
	else
		self.direction = -1
	end
	self.logic_direction = direction
	for child_name, _ in pairs(self.change_pos_child) do
		local child_info = self.child_list[child_name]
		local child = child_info.obj
		local x, y = child:getPosition()
		child:setPosition(child_info.raw_x * self.direction, y)
		child:setScaleX(math.abs(child:getScaleX()) * self.direction)
	end
end