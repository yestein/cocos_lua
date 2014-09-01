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

-- WaitHelper.is_debug = 1

function WaitHelper:_Uninit()
	self.next_job_id        = nil
	self.complete_call_back = nil
	self.job_count          = nil
	self.job_list           = nil

	return 1
end

function WaitHelper:_Init(complete_call_back)
	self.job_list = {}
	self.job_count = 0
	self.complete_call_back = complete_call_back
	self.next_job_id = 1
	return 1
end

function WaitHelper:WaitJob(max_wait_time, func_over_time)
	local job_id = self.next_job_id
	self.next_job_id = self.next_job_id + 1
	self.job_list[job_id] = {func_over_time}
	self:RegistRealTimer(max_wait_time * GameMgr:GetFPS(), {self.OnTimeOver, self, job_id})
	self.job_count = self.job_count + 1
	if self.is_debug == 1 then
		print("wait job", job_id)
		print("job count:", self.job_count)
	end
	return job_id
end

function WaitHelper:OnTimeOver(job_id, timer_id)
	local func_timer_over = self.job_list[job_id][1]
	if func_timer_over then
		func_timer_over(job_id)
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