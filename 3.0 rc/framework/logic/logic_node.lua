--=======================================================================
-- File Name    : logic_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 19:41:26 2014
-- Description  :
-- Modify       :
--=======================================================================

if not LogicNode then
	LogicNode = {
		max_order = 1,
		child_list = {},
		child_list_order = {},
	}
end

function LogicNode:UninitChild()
	if self.child_list then
		for name, child in pairs(self.child_list) do
			child:ReceiveMessage("Uninit")
		end
		self.child_list = nil
	end
end

function LogicNode:GetParent()
	return self.__parent
end

function LogicNode:AddChild(child_name, child_node, order)
	if not order then
		order = self.max_order + 1
	end
	assert(not self.child_list[child_name])
	assert(not self.child_list_order[order])
	self.child_list[child_name] = child_node
	self.child_list_order[order] = child_node
	child_node.__parent = self
	self.max_order = order
end

function LogicNode:GetChild(child_name)
	return self.child_list[child_name]
end

function LogicNode:ReceiveMessage(msg, ...)
	if type(self[msg]) == "function" then
		local result = self[msg](self, ...)
		if result == 1 then
			return result
		end
	end
	if not self.child_list then
		return
	end
	for i = 1, self.max_order do
		local child = self.child_list_order[order]
		if child and child.ReceiveMessage then
			local result = child:ReceiveMessage(msg, ...)
			if result == 1 then
				return result
			end
		end
	end
end

function LogicNode:DeclareListenEvent(event_type, fun_name)
	if not self.event_listener then
		self.event_listener = {}
	end
	self.event_listener[event_type] = fun_name
end

function LogicNode:RegisterEventListen()
	if not self.event_listener then
		return
	end
	if not self.reg_event_list then
		self.reg_event_list = {}
	end
	Lib:ShowTB(self.event_listener)
	for event_type, func in pairs(self.event_listener) do
		if not self.reg_event_list[event_type] then
			local id_reg = Event:RegistEvent(event_type, self[func], self)
			self.reg_event_list[event_type] = id_reg
		else
			assert(false, event_type)
		end
	end
end

function LogicNode:UnregisterEventListen()
	if not self.reg_event_list then
		return
	end
	for event_type, id_reg in pairs(self.reg_event_list) do
		Event:UnRegistEvent(event_type, id_reg)
	end
	self.reg_event_list = {}
end