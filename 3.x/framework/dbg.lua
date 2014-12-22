--=======================================================================
-- File Name    : debug.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-12-2 20:32:24
-- Description  :
-- Modify       :
--=======================================================================

if not Debug then
	Debug = {}
end

Debug.MODE_BLACK_LIST = 1
Debug.MODE_WHITE_LIST = 2

Debug.watch_event_list = {

}

Debug.watch_event_black_list = {

}

function cclog(fmt, ...)
    return Log:Print(Log.LOG_ERROR, fmt, ...)
end

function PrintEvent(log_level, ...)
	local text = ""
	local count = select("#", ...)
	for i = 1, count do
		text = text .. "\t" .. tostring(select(i, ...))
	end
	return Log:Print(log_level, "[Event] %s", text)
end

function Debug:AddBlackEvent(event_type, log_level)
	self.watch_event_black_list[event_type] = log_level or Log.LOG_DEBUG
end

function Debug:AddWhiteEvent(event_type, log_level)
	self.watch_event_list[event_type] = log_level or Log.LOG_DEBUG
end

function Debug:Init(mode)
	self:SetMode(mode)

	return 1
end

function Debug:SetMode(mode)
	self.mode = mode
	if mode == self.MODE_BLACK_LIST then
		Event:RegistWatcher(Debug.watch_event_black_list, PrintEvent)
	elseif mode == self.MODE_WHITE_LIST then
		self.event_watch_list = {}
		for event_type, log_level in pairs(Debug.watch_event_list) do
			self.event_watch_list[event_type] = Event:RegistEvent(event_type, PrintEvent, log_level, event_type)
		end
	end
end

function Debug:ChangeMode(mode)
	if self.mode == mode then
		return
	end
	if self.mode == self.MODE_BLACK_LIST then
		Event:UnRegistWatcher()
	elseif self.mode == self.MODE_WHITE_LIST then
		for event_type, id in pairs(self.event_watch_list) do
			Event:UnRegistEvent(event_type, id)
		end
		self.event_watch_list = {}
	end
	self:SetMode(mode)
end

function Debug:ShowTimer()
	print("=====Real Event============")
	Lib:ShowTB(RealTimer.frame_event)
	print("=====Real CallBack============")
	Lib:ShowTB(RealTimer.call_back_list, 2)
	print("=====Logic Event=============")
	Lib:ShowTB(LogicTimer.frame_event)
	print("=====Logic CallBack============")
	Lib:ShowTB(LogicTimer.call_back_list, 2)
end