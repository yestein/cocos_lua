--=======================================================================
-- File Name    : log.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/27 16:25:53
-- Description  : log system
-- Modify       :
--=======================================================================
if not Log then
    Log = {}
end

Log.LOG_DEBUG   = 1
Log.LOG_INFO    = 2
Log.LOG_WARNING = 3
Log.LOG_ERROR   = 4

local LOG_TEXT = {
    [Log.LOG_DEBUG  ] = "DEBUG",
    [Log.LOG_INFO   ] = "INFO",
    [Log.LOG_WARNING] = "WARNING",
    [Log.LOG_ERROR  ] = "ERROR",
}

function Log:Init(log_level, view_level, prefix)
    local log_path = self:GetLogFileByTime(prefix or "log")
    self.fp = io.open(__write_path..log_path, "w")
    if not self.fp then
        return 0
    end
    self.log_level = log_level or Log.LOG_DEBUG
    self.view_level = view_level or Log.LOG_INFO
    return 1
end

function Log:GetLogFileByTime(prefix)
    local t = os.date("*t",time)
    local file_name = string.format("%s_%d_%02d_%02d_%02d_%02d_%02d.log", prefix, t.year, t.month, t.day, t.hour, t.min, t.sec)
    if cc then
        if __platform == cc.PLATFORM_OS_WINDOWS then
        file_name = "log\\"..file_name
    end
    else
    file_name = "log/"..file_name
    end
    return file_name
end

function Log:CheckLevel(log_level)
    if log_level > self.LOG_ERROR then
        log_level = self.LOG_ERROR
    elseif log_level < self.LOG_DEBUG then
        log_level = self.LOG_DEBUG
    end
    return log_level
end

function Log:SetLogLevel(name, log_level)
    log_level = Log:CheckLevel(log_level)
    self.log_level = log_level
end

function Log:SetViewLevel(name, view_level)
    view_level = Log:CheckLevel(view_level)
    self.view_level = view_level
end

function Log:ParseText(fmt, ...)
    local result, text = pcall(string.format, fmt, ...)
    if not result then
        local count = select("#", ...)
        text = fmt
        for i = 1, count do
            text = text .. "\t" .. tostring(select(i, ...))
        end
    end
    return text
end

function Log:Print(log_level, fmt, ...)
    return self:_Print(log_level, self:ParseText(fmt, ...))
end

function Log:_Print(log_level, text)
    if self.log_level and log_level >= self.log_level then
        self:WriteLog(log_level, text)
    end
    if not self.view_level or log_level >= self.view_level then
        print(text)
    end
    return text
end

function Log:WriteLog(log_level, text)
    if not self.fp then
        return
    end
    local time_text = os.date("%Y-%m-%d %H:%M:%S")
    local content = string.format("[%s][%s] %s",
        LOG_TEXT[log_level] or tostring(log_level),
        time_text, text)
    self.fp:write(content.."\n")
    self.fp:flush()
end
