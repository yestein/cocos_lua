--=======================================================================
-- File Name    : real_timer.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/1 20:41:20
-- Description  : real timer, no not effect by game pause
-- Modify       : 
--=======================================================================

if not RealTimer then
	RealTimer = Class:New(TimerBase, "RealTimer")
end

function RealTimer:RegistCocosTimerByCount(count, call_back)
	local handle = nil
	local director = cc.Director:getInstance()
	local touch_frame = director:getTotalFrames()
	local end_frame = touch_frame + count
	local function onTimer()
		local current_frame = director:getTotalFrames()
		local rest_count = end_frame - current_frame
		call_back[#call_back + 1] = rest_count
		Lib:SafeCall(call_back)
		call_back[#call_back] = nil
		if rest_count <= 0 then
			director:getScheduler():unscheduleScriptEntry(handle)
		end
	end
	handle = director:getScheduler():scheduleScriptFunc(onTimer, 0, false)
	return handle
end

function RealTimer:RegistCocosTimerOnce(time, call_back)
	local handle = nil
	local director = cc.Director:getInstance()
	local function onTimer()
		Lib:SafeCall(call_back)
		director:getScheduler():unscheduleScriptEntry(handle)		
	end
	handle = director:getScheduler():scheduleScriptFunc(onTimer, time, false)
	return handle
end

function RealTimer:UnregistCocosTimer(handle)
	return cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
end