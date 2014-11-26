--=======================================================================
-- File Name    : stat.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/11/25 10:21:58
-- Description  : description
-- Modify       : 
--=======================================================================

require("socket.core")

if not Stat then
	Stat = {
		is_running = 0,
		call_func_time = {},
		total_func_time = {},
		last_stat_tb = nil
	}
end

function Stat:Reset()
	self.call_func_time = {}
	self.total_func_time = {}
	self.last_stat_tb = nil
end

function Stat:Debug()
	print("is_running", self.is_running)
	Lib:ShowTB(self.call_func_time, 30)
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
	
	local stat_time = socket:gettime()
	return function()
		local diff_time = socket:gettime() - stat_time
		stat_tb.run_time = stat_tb.run_time + diff_time
		self.last_stat_tb = last_stat_tb
		if not self.total_func_time[name] then
			self.total_func_time[name] = 0
		end
		self.total_func_time[name] = self.total_func_time[name] + diff_time
		return diff_time
	end
end

function Stat:GetData()
	return self.call_func_time
end

function Stat:Analyst()
	local data = self:GetData()
	for name, process_data in pairs(data) do
		print(string.format("[%s] %.4f", name, process_data.run_time))
		self:Output(process_data.run_time, process_data._child, 1)
	end
	print("======Top Function=========")
	local tb = {}
	for k, value in pairs(self.total_func_time) do
		table.insert(tb, {name = k, run_time = value})
	end
	local function cmp(a, b)
		return a.run_time > b.run_time
	end
	table.sort(tb, cmp)
	for index = 1, 10 do
		local data = tb[index]
		if data then
			print(string.format("[%d] %7.4f %s", index, data.run_time, data.name))
		end
	end
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
		print(string.format("%s[%s] --%6.4f%% (%.4f)", pre_blank, name, process_data.run_time * 100 / total_time, process_data.run_time))
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


local function TestStat()
	Stat:Reset()
	Stat:SetRunning(1)	
	for i = 1, 10 do
		temp = 0
		A_a()
	end
	Stat:SetRunning(0)
	Stat:Analyst()
	return 1
end
AddInitFunction("StatTest", TestStat)
