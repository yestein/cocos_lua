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
				showTB(v, deepth + 1, max_deepth - 1)
			end
		end
	end
	showTB(table_raw, 1, 7)
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
	local offset_x = (x - start_x) / cell_width
	local offset_y = (y - start_y) / cell_height

	return self:_GetDiamondLogicPosition(offset_x, offset_y)
end

function Lib:_GetDiamondLogicPosition(offset_x, offset_y)
	local minus = 1
	if offset_x < 0 then
		offset_x = offset_x * -1
		minus = -1
	end

	offset_y = offset_y * -1

	-- print(offset_x, offset_y)
	local x = nil
	local y = nil

	--奇数格子
	x = math.floor((offset_x + 0.5)) * minus
	y = math.floor(offset_y)

	local odd_column = x + y
	local odd_row = y - x
	-- print("odd_row", odd_row + 1)
	-- print("odd_column", odd_column + 1)

	--偶数格子
	local even_column = nil
	local even_row = nil
	x = math.ceil(offset_x) * minus
	y = math.ceil(offset_y - 0.5)
	if y > 0 then
		if x > 0 then
			even_column = x + y - 1
			even_row = y - x
		else
			even_column = x + y
			even_row = y - x - 1
		end
	end

	if not even_row then
		return odd_row + 1, odd_column + 1
	end

	-- print("even_row", even_row + 1)
	-- print("even_column", even_column + 1)

	local odd_center_x, odd_center_y = self:_GetDiamondPosition(odd_row + 1, odd_column + 1)
	local even_center_x, even_center_y = self:_GetDiamondPosition(even_row + 1, even_column + 1)
	local distance_odd = self:GetDistanceSquare(odd_center_x, odd_center_y, offset_x * minus, offset_y * (-1))
	local distance_even = self:GetDistanceSquare(even_center_x, even_center_y, offset_x * minus, offset_y * (-1))
	-- print(odd_center_x, odd_center_y, offset_x * minus, offset_y * (-1))
	-- print(even_center_x, even_center_y, offset_x * minus, offset_y * (-1))
	if distance_odd <= distance_even then
		return odd_row + 1, odd_column + 1
	else
		return even_row + 1, even_column + 1
	end
end