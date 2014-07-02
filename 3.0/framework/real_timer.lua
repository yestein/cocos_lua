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
		Trigger(self.call_back_list[timer_id])
		self.call_back_list[timer_id] = nil
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
	local timer_id = #self.call_back_list + 1
	call_back[#call_back + 1] = timer_id
	self.call_back_list[timer_id] = {call_back, frame}

	local current_frame = self.num_frame
	local frame_index = current_frame + math.ceil(frame)
	if not self.frame_event[frame_index] then
		self.frame_event[frame_index] = {}
	end
	table.insert(self.frame_event[frame_index], timer_id)
	return timer_id
end

function RealTimer:CloseTimer(timer_id)
	self.call_back_list[timer_id] = nil
end