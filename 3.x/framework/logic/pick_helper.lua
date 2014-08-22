--=======================================================================
-- File Name    : pick_helper.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Fri Aug 22 07:39:33 2014
-- Description  : pick object
-- Modify       : 
--=======================================================================
if not PickHelper then
	PickHelper = NewLogicNode("PickHelper")
end

function PickHelper:_Uninit()
	self.timer_id = nil
	self.is_working = nil
	self.container = nil
	self.offset_y = nil
	self.offset_x = nil
end

function PickHelper:_Init(max_pick_num)
	self.pick_num = 0
	self.max_pick_num = max_pick_num
	self.container = {}
	self.timer_id = nil
	return 1
end

function PickHelper:GetPickNum()
	return self.pick_num
end

function PickHelper:CanPick()
	if self.pick_num >= self.max_pick_num then
		return 0
	end
	return 1
end

function PickHelper:Pick(id, x, y)
	if self.pick_num >= self.max_pick_num or self.container[id] then
		return 0
	end

	self.container[id] = {x, y}
	self.pick_num = self.pick_num + 1

	Event:FireEvent("PICKHELPER.PICK", id, x , y)
	return 1
end

function PickHelper:CancelPick(id)
	self.container[id] = nil
	self.pick_num = self.pick_num - 1

	Event:FireEvent("PICKHELPER.CANCEL_PICK", id)
end

function PickHelper:CancelAll()
	for id, _ in pairs(self.container) do
		self:CancelPick(id)
	end
end

function PickHelper:Drop(id, x, y)
	local info = self.container[id]
	if not info then
		return 0
	end
	local old_x, old_y = unpack(info)
	self.container[id] = nil
	self.pick_num = self.pick_num - 1

	Event:FireEvent("PICKHELPER.DROP", id, x , y, old_x, old_y)
end

function PickHelper:DropAll(x, y)
	for id, _ in pairs(self.container) do
		self:Drop(id, x, y)
	end
end

function PickHelper:GetAll()
	return self.container
end

function PickHelper:Clear()
	self.container = {}
	self.pick_num = 0
end