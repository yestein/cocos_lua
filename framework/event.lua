--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not Event then
	Event = {}
end

function CPPEvent(...)
	Event:FireEvent(...)
end

function Event:Preload()
	self.global_event_list = {}
end

function Event:Debug()
	Lib:ShowTB(self.global_event_list)
end

function Event:RegistWatcher(event_black_list, watcher_call_back_function)
	self.event_black_list = event_black_list
	self.watcher_call_back_function = watcher_call_back_function
end

function Event:RegistEvent(event_type, function_call_back, ...)
	if not event_type or not function_call_back then
		print(event_type, function_call_back)
		assert(false)
		return
	end
	if not self.global_event_list[event_type] then
		self.global_event_list[event_type] = {}
	end
	local call_back_list = self.global_event_list[event_type]
	local register_id = #call_back_list + 1
	call_back_list[register_id] = {function_call_back, {...}}
	return register_id
end

function Event:UnRegistEvent(event_type, register_id)
	if not event_type or not register_id then
		assert(false)
		return
	end
	if not self.global_event_list[event_type] then
		return 0
	end
	local call_back_list = self.global_event_list[event_type]
	if not call_back_list[register_id] then
		return 0
	end
	call_back_list[register_id] = nil
	return 1
end

function Event:FireEvent(event_type, ...)
	self:CallBack(self.global_event_list[event_type], ...)
	if self.watcher_call_back_function then
		if not self.event_black_list or not self.event_black_list[event_type] then
			self.watcher_call_back_function(event_type, ...)
		end
	end
end


function Event:CallBack(event_list, ...)
	if not event_list then
		return
	end
	local event_list_copy = Lib:CopyTB1(event_list)
	for register_id, callback in pairs(event_list_copy) do
		if event_list[register_id] then
			local call_back_function = callback[1]
			local call_back_args = callback[2]

			if #call_back_args > 0 then
				Lib:SafeCall({call_back_function, unpack(call_back_args), ...})
			else
				Lib:SafeCall({call_back_function, ...})
			end
		end
	end
end