--=======================================================================
-- File Name    : stat.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/11/25 10:21:58
-- Description  : description
-- Modify       :
--=======================================================================

if not Stat then
    Stat = {
        is_running = 0,
        call_func_time = {},
        total_func_time = {},
        last_stat_tb = nil,
        event_count = {},
    }
end

function Stat:Reset()
    self.call_func_time = {}
    self.total_func_time = {}
    self.last_stat_tb = nil
    self.event_count = {}
end

function Stat:Debug()
    log_print("is_running", self.is_running)
    Lib:ShowTB(self.call_func_time, 30)
end

function Stat:IsRunning()
    return self.is_running
end

function Stat:SetRunning(is_running)
    self.is_running = is_running
end

function Stat:GetStatFunc(name)
    if self.is_running ~= 1 then
        return nil
    end

    local last_stat_tb = self.last_stat_tb
    local stat_tb = nil

    if last_stat_tb then
        if not last_stat_tb._child[name] then
            last_stat_tb._child[name] = {run_time = 0, _child = {},}
        end
        stat_tb = last_stat_tb._child[name]
    else
        if not self.call_func_time[name] then
            self.call_func_time[name] = {run_time = 0, _child = {},}
        end
        stat_tb = self.call_func_time[name]
    end
    self.last_stat_tb = stat_tb

    local stat_time = gettime()
    return function()
        local diff_time = gettime() - stat_time
        stat_tb.run_time = stat_tb.run_time + diff_time
        self.last_stat_tb = last_stat_tb
        if not self.total_func_time[name] then
            self.total_func_time[name] = {time = 0, count = 0,}
        end
        self.total_func_time[name].time = self.total_func_time[name].time + diff_time
        self.total_func_time[name].count = self.total_func_time[name].count + 1
        return diff_time
    end
end

function Stat:GetData()
    return self.call_func_time
end

function Stat:Analyst(total_time)
    local data = self:GetData()
    for name, process_data in pairs(data) do
        log_print(string.format("[%s] %6.4f%% (%7.4f)", name, process_data.run_time * 100 / total_time, process_data.run_time))
        self:Output(total_time or process_data.run_time, process_data._child, 1)
    end
    log_print("======Top Function=========")
    local result_tb = {}
    for name, process_data in pairs(data) do
        self:_FilterTopFunction(name, process_data, result_tb)
    end
    local tb = {}
    for k, value in pairs(result_tb) do
        table.insert(tb, {name = k, run_time = value})
    end
    local function cmp(a, b)
        return a.run_time > b.run_time
    end
    table.sort(tb, cmp)
    if not total_time then
        total_time = tb[1].run_time
    end
    for index = 1, 10 do
        local data = tb[index]
        if data then
            log_print(string.format("[%d] %5.3f%%(%7.4f) %s count:%d", index, data.run_time * 100 / total_time, data.run_time, data.name, self.total_func_time[data.name].count))
        end
    end
    log_print("======Top Event=========")
    local tb = {}
    for k, v in pairs(self.event_count) do
        table.insert(tb, {k, v})
    end
    local function cmp(a, b)
        return a[2] > b[2]
    end
    table.sort(tb, cmp)
    for index = 1, 10 do
        local data = tb[index]
        if data then
            log_print(string.format("[%d] %s count:%d", index, data[1], data[2]))
        end
    end
end

function Stat:_FilterTopFunction(name, data, result_tb)
    if not data then
        return 0
    end
    local run_time = data.run_time
    for process_name, process_data in pairs(data._child) do
        run_time = run_time - self:_FilterTopFunction(process_name, process_data, result_tb)
    end
    if not result_tb[name] then
        result_tb[name] = 0
    end
    result_tb[name] = result_tb[name] + run_time
    return data.run_time
end

function Stat:Output(total_time, data, depth)
    if not data then
        return
    end
    local pre_blank = ""
    for i = 1, depth do
        if i ~= depth then
            pre_blank = pre_blank .. "  "
        else
            pre_blank = pre_blank .. "|- "
        end
    end
    for name, process_data in pairs(data) do
        log_print(string.format("%s[%s] --%6.4f%% (%.4f)", pre_blank, name, process_data.run_time * 100 / total_time, process_data.run_time))
        self:Output(total_time, process_data._child, depth + 1)
    end
end

local A_a = nil

local temp = 0
local function A_c()
    local fun = Stat:GetStatFunc("c")
    if temp == 0 then
        temp = temp + 1
        A_a()
    end
    local fun1 = Stat:GetStatFunc("collect")
    collectgarbage("collect")
    fun1()
    fun()
end

local function A_b()
    local fun = Stat:GetStatFunc("b")
    A_c()
    fun()
end

A_a = function()
    local fun = Stat:GetStatFunc("a")
    A_b()
    fun()
end


function Stat:TestStat()
    Stat:Reset()
    Stat:SetRunning(1)
    local stat_time = gettime()
    for i = 1, 10 do
        temp = 0
        A_a()
    end
    Stat:SetRunning(0)
    local time = gettime() - stat_time
    Stat:Analyst(time)
    return 1
end
