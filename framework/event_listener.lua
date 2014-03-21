--=======================================================================
-- File Name    : event_listener.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 
-- Description  :
-- Modify       :
--=======================================================================

if not EventListener then
	EventListener = {}
end


function EventListener:DeclareListenEvent(event_type, fun_name)
	if not self.event_listener then
		self.event_listener = {}
	end
	self.event_listener[event_type] = fun_name
end

function EventListener:RegisterEventListen()
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
			assert(false)
		end
	end
end

function EventListener:UnregisterEventListen()
	if not self.reg_event_list then
		return
	end
	for event_type, id_reg in pairs(self.reg_event_list) do
		Event:UnRegistEvent(event_type, id_reg)
	end
	self.reg_event_list = {}
end