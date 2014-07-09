--=======================================================================
-- File Name    : real_timer.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/1 20:41:20
-- Description  : real timer, no not effect by game pause
-- Modify       : 
--=======================================================================

if not RealTimer then
	RealTimer = {}
end

function RealTimer:Init()
	self.call_back_list = {}
	self.frame_event = {}
	self.num_frame = 0
end

function RealTimer:Uninit()
	self.num_frame = nil
	self.frame_event = nil
	self.call_back_list = nil
end

function RealTimer:OnActive()
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
		if not is_success or not result then
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
function RealTimer:RegistTimer(frame, call_back)
	assert(frame > 0)
	local current_frame = self.num_frame
	local frame_index = current_frame + math.ceil(frame)

	local timer_id = #self.call_back_list + 1
	call_back[#call_back + 1] = timer_id
	self.call_back_list[timer_id] = {call_back, frame, frame_index}

	
	if not self.frame_event[frame_index] then
		self.frame_event[frame_index] = {}
	end
	table.insert(self.frame_event[frame_index], timer_id)
	return timer_id
end

function RealTimer:CloseTimer(timer_id)
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