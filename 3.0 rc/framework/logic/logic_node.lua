--=======================================================================
-- File Name    : logic_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 19:41:26 2014
-- Description  :
-- Modify       :
--=======================================================================

if not LogicNode then
	LogicNode = {}
end

function LogicNode:UninitChild()
	if self.child_list then
		for name, child in pairs(self.child_list) do
			child:SendMessage("Uninit")
		end
		self.child_list = nil
	end
end

function LogicNode:GetParent()
	return self.__parent
end

function LogicNode:AddChild(child_name, child_node)
	assert(not self.child_list[child_name])
	self.child_list[child_name] = child_node
	child_node.__parent = self
end

function LogicNode:GetChild(child_name)
	return self.child_list[child_name]
end

function LogicNode:SendMessage(msg, ...)
	if type(self[msg]) == "function" then
		local result = self[msg](self, ...)
		if result == 1 then
			return result
		end
	end
	if not self.child_list then
		return
	end
	for name, child in pairs(self.child_list) do
		if child.SendMessage then
			local result = child:SendMessage(msg, ...)
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