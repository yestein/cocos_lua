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

function Debug:SetEventLogPath(file_path)
	if file_path then
		self.fp = io.open(file_path, "w")
	elseif self.fp then
		io.close(self.fp)
	end
end

function Debug:AddBlackEvent(event_type)
	self.watch_event_black_list[event_type] = 1
end

function Debug:Init(mode)
	return self:SetMode(mode)
end

function Debug:SetMode(mode)
	self.mode = mode
	if mode == self.MODE_BLACK_LIST then
		Event:RegistWatcher(Debug.watch_event_black_list, self.Print)
	elseif mode == self.MODE_WHITE_LIST then
		self.event_watch_list = {}
		for _, event_type in ipairs(Debug.watch_event_list) do
			self.event_watch_list[event_type] = Event:RegistEvent(event_type, self.Print, event_type)
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

function Debug.Print(...)
	local text = ""
	for _, v in ipairs({...}) do
		text = text .. "\t" .. tostring(v)
	end
	if Debug.fp then
		local time_text = os.date("%Y-%m-%d %H:%M:%S")
		local content = string.format("[%s]%s", time_text, text)
		Debug.fp:write(text)
	else
		print(text)
	end
end

function Debug.Printf(Fmt, ...)
	if select("#", ...) <= 0 then
		print(Fmt)
	else
		print(string.format(Fmt, ...))
	end
end
