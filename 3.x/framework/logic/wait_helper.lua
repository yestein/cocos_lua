--=======================================================================
-- File Name    : wait_helper.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Aug 31 11:24:04 2014
-- Description  : for wait some obj complete their jobs
-- Modify       :
--=======================================================================

if not WaitHelper then
	WaitHelper = NewLogicNode("WaitHelper")
end

function WaitHelper:_Uninit()
	self.max_wait_frame = nil
	self.job_count     = nil
	self.job_list      = nil
end

function WaitHelper:_Init(max_wait_time, complete_call_back, func_timer_over)
	self.job_list = {}
	self.job_count = 0
	self.max_wait_frame = max_wait_time * GameMgr:GetFPS()
	self.complete_call_back = complete_call_back
	self.func_timer_over = func_timer_over
	return 1
end

function WaitHelper:WaitJob(id)
	assert(not self.job_list[id])
	self.job_list[id] = self:RegistRealTimer(self.max_wait_frame, {self.OnTimeOver, self, id})
	self.job_count = self.job_count + 1
	print("wait job", id)
	print("job count:", self.job_count)
end


function WaitHelper:OnTimeOver(id, timer_id)
	if self.func_timer_over then
		self.func_timer_over(id)
	end
	self:JobComplete(id)
end

function WaitHelper:JobComplete(id)
	local timer_id = self.job_list[id]
	self:UnregistRealTimer(timer_id)
	self.job_list[id] = nil
	self.job_count = self.job_count - 1
	print("job complete", id)
	print("job count:", self.job_count)


	if self.job_count <= 0 then
		Lib:SafeCall(self.complete_call_back)
		self.complete_call_back = nil
	end
end