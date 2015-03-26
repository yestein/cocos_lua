--=======================================================================
-- File Name    : logic_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Thu Mar 27 19:41:26 2014
-- Description  :
-- Modify       :
--=======================================================================

if not LogicNode then
	LogicNode = Class:New(nil, "LOGIC_NODE")
end

function NewLogicNode(name)
	assert(name)
	local node = Class:New(LogicNode, name)
	return node
end

function LogicNode:_Init( ... )	
	self:RegisterEventListen()
	self.real_timer_id_list = {}
	self.logic_timer_id_list = {}
	return 1
end

function LogicNode:_Uninit( ... )
	self.__uninit = 1
	self:UnRegistAllTimer()
	self.real_timer_id_list = nil
	self.logic_timer_id_list = nil
	
	self:UninitChild()
	self:UnregisterEventListen()
	self.max_order        = nil
	self.child_list       = nil
	self.child_list_order = nil
	self.reg_event_list   = nil
	self.is_debug		  = nil

	return 1
end

function LogicNode:EnableDebug(is_debug)
	self.is_debug = is_debug
end

function LogicNode:IsDebug()
	return self.is_debug
end

function LogicNode:UninitChild()
	if not self.child_list then
		return
	end
	for name, child in pairs(self.child_list) do
		child:ReceiveMessage("Uninit")
	end
	self.child_list = nil
end

function LogicNode:GetParent()
	return self.__parent
end

function LogicNode:AddChild(child_name, child_node, order)
	if not self.max_order then
		self.max_order = 0
	end
	if not self.child_list then
		self.child_list = {}
	end

	if not self.child_list_order then
		self.child_list_order = {}
	end

	if not order then
		order = self.max_order + 1
	end
	assert(not self.child_list[child_name])
	assert(not self.child_list_order[order])
	self.child_list[child_name] = child_node
	self.child_list_order[order] = child_node
	child_node.__parent = self
	self.max_order = order
	assert(self:RegistChildMessageHandler(child_name) == 1)
end

function LogicNode:RemoveChild(child_name)
	if not self.max_order then
		return
	end
	if not self.child_list then
		return
	end

	if not self.child_list_order then
		return
	end

	if not order then
		order = self.max_order + 1
	end
	assert(self.child_list[child_name])

	for i = 1, self.max_order do
		if self.child_list_order[i] == self.child_list[child_name] then
			self.child_list_order[i] = nil
			break
		end
	end
	self.child_list[child_name] = nil
end

function LogicNode:GetChild(child_name)
	if not self.child_list then
		return
	end
	return self.child_list[child_name]
end

function LogicNode:ForEachChild(callback, ...)
	if not self.child_list then
		return
	end

	for child_name, child_node in pairs(self.child_list) do
		callback(child_name, child_node, ...)
	end
end

function LogicNode:QueryFunction(func_name)
	local item = self[func_name]
	if item and type(item) == "function" then
		return item
	end
end

function LogicNode:QueryFunctionWithChild(func_name)
	local result = {}
	local func = nil
	func = self:QueryFunction(func_name)
	if func then
		table.insert(result, {func, self})
	end
	if not self.child_list then
		return result
	end

	for i = 1, self.max_order do
		local child = self.child_list_order[i]
		if child and child.ReceiveMessage then

			func = child:QueryFunction(func_name)
			if func then
				table.insert(result, {func, child})
			end
		end
	end

	return result
end

function LogicNode:TryCall(func_name, ...)
	local func = nil
	func = self:QueryFunction(func_name)
	if func then
		return func(self, ...)
	end
	if not self.child_list then
		return
	end

	for i = 1, self.max_order do
		local child = self.child_list_order[i]
		if child and child.QueryFunction then
			func = child:QueryFunction(func_name)
			if func then
				return func(child, ...)
			end
		end
	end
	-- cclog("No Function[%s]", func_name)
end

function LogicNode:ReceiveMessage(msg, ...)
	local func_name = msg
	local result = self:QueryFunctionWithChild(func_name)
	for _, body in ipairs(result) do
		local func, owner = unpack(body)
		func(owner, ...)
		if self.__uninit == 1 then
			return
		end
	end
end

function LogicNode:SendMessage(msg, ...)
	local func_list = self.msg_handler[msg]
	if not func_list then
		return 0
	end
	for child_name, func in pairs(func_list) do
		local child = self:GetChild(child_name)
		if not child then
			func_list[child_name] = nil
		else
			return 1, func(child, ...)
		end
	end
	return 0
end

function LogicNode:RegistChildMessageHandler(child_name)
	local child = self:GetChild(child_name)
	if not child then
		assert(false)
		return 0
	end
	if not child.msg_list then
		return 1
	end
	if not self.msg_handler then
		self.msg_handler = {}
	end
	for msg, func_name in pairs(child.msg_list) do
		if not self.msg_handler[msg] then
			self.msg_handler[msg] = {}
		end
		local func = child[func_name]
		self.msg_handler[msg][child_name] = func
	end
	return 1
end

function LogicNode:DeclareHandleMsg(msg, func_name)
	if not self.msg_list then
		self.msg_list = {}
	end
	self.msg_list[msg] = func_name
end


function LogicNode:DeclareListenEvent(event_type, func_name)
	if not self.event_listener then
		self.event_listener = {}
	end
	self.event_listener[event_type] = func_name
end

function LogicNode:RegisterEventListen()
	if not self.event_listener then
		return
	end
	if not self.reg_event_list then
		self.reg_event_list = {}
	end
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

function LogicNode:Print(log_level, fmt, ...)
	local log_node = self:GetChild("log")
	if not log_node then
		print(fmt, ...)
		return
	end
	log_node:Print(log_level, fmt, ...)
end

function LogicNode:AddComponent(child_name, component_name, ...)
	local component = ComponentMgr:NewComponent(component_name)
	component:Init(...)
	self:AddChild(child_name, component)
	return component
end

function LogicNode:RegistRealTimer(frame, call_back)
	local timer_id = RealTimer:RegistTimer(frame, {self.OnRealTimer, self, call_back})
	if timer_id then
		self.real_timer_id_list[timer_id] = 1
	end
	return timer_id
end

function LogicNode:RegistRealTimerBySeconds(sec, call_back)
	return self:RegistRealTimer(math.floor(sec * GameMgr:GetFPS()), call_back)
end

function LogicNode:UnregistRealTimer(timer_id)
	RealTimer:CloseTimer(timer_id)
	self.real_timer_id_list[timer_id] = nil
end

function LogicNode:OnRealTimer(call_back, timer_id)
	if timer_id then
		self.real_timer_id_list[timer_id] = nil
	end
	Lib:SafeCall(call_back)	
end

function LogicNode:RegistLogicTimer(frame, call_back)
	local timer_id = LogicTimer:RegistTimer(frame, {self.OnLogicTimer, self, call_back})
	if timer_id then
		self.logic_timer_id_list[timer_id] = 1
	end
	return timer_id
end

function LogicNode:RegistLogicTimerBySeconds(sec, call_back)
	return self:RegistLogicTimer(math.floor(sec * GameMgr:GetFPS()), call_back)
end

function LogicNode:UnregistLogicTimer(timer_id)
	LogicTimer:CloseTimer(timer_id)
	self.real_timer_id_list[timer_id] = nil
end

function LogicNode:OnLogicTimer(call_back, timer_id)
	if timer_id then
		self.logic_timer_id_list[timer_id] = nil
	end
	Lib:SafeCall(call_back)	
end

function LogicNode:UnRegistAllTimer()
	for timer_id, _ in pairs(self.real_timer_id_list) do
		RealTimer:CloseTimer(timer_id)
	end
	self.real_timer_id_list = {}

	for timer_id, _ in pairs(self.logic_timer_id_list) do
		LogicTimer:CloseTimer(timer_id)
	end
	self.logic_timer_id_list = {}
end