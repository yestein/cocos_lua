--===================================================
-- File Name    : lib.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2013-08-07 13:10:13
-- Description  :
-- Modify       :
--===================================================

if not Lib then
	Lib = {}
end

local MetaTable = {
	__index = function(table, key)
		local v = rawget(table, key)
		if v then
			return v
		end
		local base_class = rawget(table, "_tbBase")
		return base_class[key]
	end
}

function Lib:NewClass(base_class)
	local new_class = { _tbBase = base_class }
	setmetatable(new_class, MetaTable)
	return new_class
end

function Lib:Show2DTB(tb, row, column)
	local title = "\t"
	for i = 1, column do
		title = title.."\t"..i
	end
	print(title)
	print("-----------------------------------------------------------------------------------------------")
	for i = 1, row do
		local msg = i.."\t|"
		if tb[row] then
			for j = 1, column do
				msg = msg .."\t"..tostring(tb[i][j])
			end
			print(msg)
		end
	end
end

function Lib:ShowTB1(tb)
	for k, v in pairs(tb) do
		print(string.format("[%s] = %s", tostring(k), tostring(v)))
	end
end

function Lib:CopyTB1(tb)
	local table_copy = {}
	for k, v in pairs(tb) do
		table_copy[k] = v
	end
	return table_copy
end

function Lib:CountTB(tb)
	local count = 0
	for k, v in pairs(tb) do
		count = count + 1
	end
	return count
end

function Lib.ShowStack(s)
	print(debug.traceback(s,2))
	return s
end

function Lib:SafeCall(callback)
	local function InnerCall()
		callback[1](unpack(callback, 2))
	end
	return xpcall(InnerCall, Lib.ShowStack)
end

function Lib:MergeTable(table_dest, table_src)
	for _, v in ipairs(table_src) do
		table_dest[#table_dest + 1] = v
	end
end

function Lib:ShowTB(table)
	return self:ShowTBN(table, 7)
end

function Lib:ShowTBN(table_raw, n)

	local function showTB(table, deepth, max_deepth)
		if deepth > n or deepth > max_deepth then
			return
		end
		local str_blank = ""
		for i = 1, deepth - 1 do
			str_blank = str_blank .. "\t"
		end
		for k, v in pairs(table) do
			if type(v) ~= "table" then
				print(string.format("%s[%s] = %s", str_blank, tostring(k), tostring(v)))
			else
				print(string.format("%s[%s] = ", str_blank, tostring(k)))
				showTB(v, deepth + 1, max_deepth)
			end
		end
	end
	showTB(table_raw, 1, n)
end

function Lib:GetDistanceSquare(x1, y1, x2, y2)

	local distance_x = x1 - x2
	local distance_y = y1 - y2
	
	return (distance_y * distance_y) + (distance_x * distance_x)
end

function Lib:GetDistance(x1, y1, x2, y2)

	local distance_x = x1 - x2
	local distance_y = y1 - y2
	
	return math.sqrt((distance_y * distance_y) + (distance_x * distance_x))
end

function Lib:GetDiamondPosition(row, column, cell_width, cell_height, start_x, start_y)
	local x, y = self:_GetDiamondPosition(row, column, cell_width, cell_height)
	local position_x = start_x + x * cell_width
	local position_y = start_y + y * cell_height

	return position_x, position_y
end

function Lib:_GetDiamondPosition(row, column)
	local x = (column - row) / 2
	local y = (1 - row - column) / 2
	return x, y
end

function Lib:GetDiamondLogicPosition(x, y, cell_width, cell_height, start_x, start_y)
	local row = math.ceil((start_x - x) / cell_width + (start_y - y) / cell_height)
	local column = math.ceil((x - start_x) / cell_width - (y - start_y) / cell_height)

	return row, column
end

function Lib:Table2Str(table)
	local table_string = "{\n"
	for k, v in pairs(table) do
		if type(k) == "number" then
			table_string = table_string .. "["..k.."]="
		elseif type(k) == "string" then
			table_string = table_string .. k .. "="
		else
			assert(false)
			return
		end

		if type(v) == "table" then
			table_string = table_string .. self:Table2Str(v)..",\n"
		elseif type(v) == "string" then
			-- TODO: string escape
			table_string = table_string .. string.format("%q", v) .. ",\n"
		else
			table_string = table_string .. tostring(v)..",\n"
		end
	end
	table_string = table_string .. "}"
	return table_string
end

function Lib:Str2Val(str)
	return assert(loadstring("return"..str)())
end

function Lib:SaveFile(file_path, content)
	local file = io.open(file_path, "w")
	if not file then
		return 0
	end
	file:write(content)
	file:close()
	return 1
end

function Lib:LoadFile(file_path)
	local file = io.open(file_path, "r")
	if not file then
		return
	end
	local content = file:read("*all")
	file:close()
	return content
end

function Lib:GetReadOnly(tb)
	local tbReadOnly = {}
	local mt = {
		__index = tb,
		__newindex = function(tb, key, value)
			assert(false, "Error!Attempt to update a read-only table!!")
		end
	}
	setmetatable(tbReadOnly, mt)
	return tbReadOnly
end

local TIME_AREA = {
	["Beijing"] = 8 * 3600,
} 
function Lib:GetWorldTime(area)
	if not area then
		area = "Beijing"
	end
	assert(TIME_AREA[area])
	local seconds = os.time()
	return seconds + TIME_AREA[area]
end

function Lib:RegistTimer(sec, call_back)
	local call_back_param = {
		call_back = call_back,

	}
	local function timer_call_back()
		local ret, next_interval = Lib:SafeCall(call_back_param.call_back)
		if not ret then
			CCDirector:getInstance():getScheduler():unscheduleScriptEntry(call_back_param.entry_id)
			return
		end
		-- 显式重复调用
		if next_interval == -1 then
			return
		end
		CCDirector:getInstance():getScheduler():unscheduleScriptEntry(call_back_param.entry_id)
		if next_interval and next_interval > 0 then
			copy_call_back.entry_id = CCDirector:getInstance():getScheduler():scheduleScriptFunc(timer_call_back, next_interval, false)
		end
	end

	call_back_param.entry_id = CCDirector:getInstance():getScheduler():scheduleScriptFunc(timer_call_back, sec, false)
end
