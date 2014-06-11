--=======================================================================
-- File Name    : timer.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/7 14:02:32
-- Description  : a timer trigger based on logic frame
-- Modify       : 
--=======================================================================

if not Timer then
	Timer = ModuleMgr:NewModule("Timer")
end

function Timer:Init()
	self.call_back_list = {}
	self.frame_event = {}
	ModuleMgr:RegisterActive(self:GetClassName(), "OnActive")
end

function Timer:Uninit()
	ModuleMgr:UnregisterActive(self:GetClassName())
	self.frame_event = nil
	self.call_back_list = nil
end

--======================================================
-- Reigist Function Return Value:
-- n > 0 : Continue Reigst a same timer n frames later
-- n <= 0: Continue Reigst a same timer with same frames last regist
-- no return or return nil: Nothing happen
--======================================================
function Timer:RegistTimer(frame, call_back)
	assert(frame > 0)
	local timer_id = #self.call_back_list + 1
	self.call_back_list[timer_id] = {call_back, frame}

	local current_frame = GameMgr:GetCurrentFrame()
	local frame_index = current_frame + math.ceil(frame)
	if not self.frame_event[frame_index] then
		self.frame_event[frame_index] = {}
	end
	table.insert(self.frame_event[frame_index], timer_id)
end

function Timer:CloseTimer(timer_id)
	self.call_back_list[timer_id] = nil
end

function Timer:OnActive(frame)
	local event_list = self.frame_event[frame]
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
	self.frame_event[frame] = nil
end