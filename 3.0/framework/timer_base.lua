--=======================================================================
-- File Name    : timer_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/10 14:42:08
-- Description  : timer base
-- Modify       : 
--=======================================================================
if not TimerBase then
	TimerBase = Class:New(nil, "TimerBase")
end

function TimerBase:_Uninit( ... )
	self.num_frame = nil
	self.frame_event = nil
	self.call_back_list = nil
	return 1
end

function TimerBase:_Init( ... )
	self.call_back_list = {}
	self.frame_event = {}
	self.num_frame = 0
	return 1
end

function TimerBase:OnActive()
	local current_frame = self.num_frame + 1
	self.num_frame = current_frame
	local event_list = self.frame_event[current_frame]
	if not event_list then
		return
	end

	local function Trigger(regist_obj)
		if not regist_obj then
			return
		end
		local is_success, result = Lib:SafeCall(regist_obj[1])
		if not is_success then
			Log:Print(Log.LOG_ERROR, regist_obj[4])
			return
		end
		if not result then
			return
		end

		local next_frame = result
		if next_frame <= 0 then
			next_frame = regist_obj[2]
		end
		self:RegistTimer(next_frame, regist_obj[1])
	end

	for _, timer_id in ipairs(event_list) do
		local regist_obj = self.call_back_list[timer_id]
		self.call_back_list[timer_id] = nil
		Trigger(regist_obj)		
	end
	self.frame_event[current_frame] = nil
end

--======================================================
-- Reigist Function Return Value:
-- n > 0 : Continue Reigst a same timer n frames later
-- n <= 0: Continue Reigst a same timer with same frames last regist
-- no return or return nil: Nothing happen
--======================================================
function TimerBase:RegistTimer(frame, call_back)
	assert(frame > 0)
	local trace_back = debug.traceback()
	local current_frame = self.num_frame
	local frame_index = current_frame + math.ceil(frame)

	local timer_id = #self.call_back_list + 1
	call_back[#call_back + 1] = timer_id
	self.call_back_list[timer_id] = {call_back, frame, frame_index, trace_back}

	
	if not self.frame_event[frame_index] then
		self.frame_event[frame_index] = {}
	end
	table.insert(self.frame_event[frame_index], timer_id)
	return timer_id
end

function TimerBase:CloseTimer(timer_id)
	if not self.call_back_list[timer_id] then
		return
	end
	local frame_index = self.call_back_list[timer_id][3]
	self.call_back_list[timer_id] = nil
	local event_list = self.frame_event[frame_index]
	local remove_index = nil
	for index, id in ipairs(event_list) do
		if id == timer_id then
			remove_index = index
			break
		end
	end
	if remove_index then
		table.remove(event_list, remove_index)
	end
	if #event_list == 0 then
		self.frame_event[frame_index] = nil
	end
end