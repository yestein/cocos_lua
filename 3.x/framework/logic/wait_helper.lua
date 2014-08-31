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

WaitHelper.is_debug = 1

function WaitHelper:_Uninit()
	self.next_job_id        = nil
	self.func_timer_over    = nil	
	self.complete_call_back = nil
	self.max_wait_frame     = nil
	self.job_count          = nil
	self.job_list           = nil

	return 1
end

function WaitHelper:_Init(max_wait_time, complete_call_back, func_timer_over)
	self.job_list = {}
	self.job_count = 0
	self.max_wait_frame = max_wait_time * GameMgr:GetFPS()
	self.complete_call_back = complete_call_back
	self.func_timer_over = func_timer_over
	self.next_job_id = 1
	return 1
end

function WaitHelper:WaitJob()
	local job_id = self.next_job_id
	self.next_job_id = self.next_job_id + 1
	self.job_list[job_id] = self:RegistRealTimer(self.max_wait_frame, {self.OnTimeOver, self, job_id})
	self.job_count = self.job_count + 1
	if self.is_debug == 1 then
		print("wait job", job_id)
		print("job count:", self.job_count)
	end
	return job_id
end

function WaitHelper:OnTimeOver(job_id, timer_id)
	if self.func_timer_over then
		self.func_timer_over(job_id)
	end
	self:JobComplete(job_id)
end

function WaitHelper:JobComplete(job_id)
	local timer_id = self.job_list[job_id]
	self:UnregistRealTimer(timer_id)
	self.job_list[job_id] = nil
	self.job_count = self.job_count - 1
	if self.is_debug == 1 then
		print("job complete", job_id)
		print("job count:", self.job_count)
	end

	if self.job_count <= 0 then
		Lib:SafeCall(self.complete_call_back)
		self.complete_call_back = nil
	end
end