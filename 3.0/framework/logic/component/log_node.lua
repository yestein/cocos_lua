--=======================================================================
-- File Name    : log.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/27 14:55:26
-- Description  : write log
-- Modify       : 
--=======================================================================
if not LogNode then
	LogNode = NewLogicNode("LOG")
end

LogNode.SetLogLevel = Log.SetLogLevel
LogNode.WriteLog = Log.WriteLog

function LogNode:_Uninit()
	self.log_level = nil
	self.view_level = nil
	self.fp:close()
	self.module_name = nil

	return 1
end

function LogNode:_Init(name, log_level)
	local log_path = Log:GetLogFileByTime(name)	
	self.module_name = name
	self.fp = io.open(__write_path..log_path, "w")
	self.log_level = log_level or Log.LOG_DEBUG

	return 1
end

function LogNode:Print(log_level, fmt, ...)
	local text = Log:ParseText(fmt, ...)
	if log_level >= self.log_level then
		self:WriteLog(log_level, text)
	end
	local log_text = string.format("[%s]%s", self.module_name, text)
	Log:_Print(log_level, log_text)	
end
