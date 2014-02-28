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
		local tbBase = rawget(table, "_tbBase")
		return tbBase[key]
	end
}

function Lib:NewClass(tbBase)
	local tbNew = { _tbBase = tbBase }
	setmetatable(tbNew, MetaTable)
	return tbNew
end

function Lib:ShowTB1(tb)
	for k, v in pairs(tb) do
		print(string.format("[%s] = %s", tostring(k), tostring(v)))
	end
end

function Lib:CopyTB1(tb)
	local tbRet = {}
	for k, v in pairs(tb) do
		tbRet[k] = v
	end
	return tbRet
end

function Lib.ShowStack(s)
	print(debug.traceback(s,2))
	return s
end

function Lib:SafeCall(tbCallBack)
	local function InnerCall()
		tbCallBack[1](unpack(tbCallBack, 2))
	end
	return xpcall(InnerCall, Lib.ShowStack)
end

function Lib:MergeTable(tbDest, tbSrc)
	for _, v in ipairs(tbSrc) do
		tbDest[#tbDest + 1] = v
	end
end

function Lib:ShowTBN(tb, n)

	local function showTB(tbValue, nDeepth, nMaxDeep)
		if nDeepth > n or nDeepth > 4 then
			return
		end
		local szBlank = ""
		for i = 1, nDeepth - 1 do
			szBlank = szBlank .. "\t"
		end
		for k, v in pairs(tbValue) do
			if type(v) ~= "table" then
				print(string.format("%s[%s] = %s", szBlank, tostring(k), tostring(v)))
			else
				print(string.format("%s[%s] = ", szBlank, tostring(k)))
				showTB(v, nDeepth + 1)
			end
		end
	end
	showTB(tb, 1)
end

function Lib:GetDistanceSquare(nLogicX_A, nLogicY_A, nLogicX_B, nLogicY_B)

	local nDistanceX = nLogicX_A - nLogicX_B
	local nDistanceY = nLogicY_A - nLogicY_B
	
	return (nDistanceY * nDistanceY) + (nDistanceX * nDistanceX)
end

function Lib:GetDistance(nLogicX_A, nLogicY_A, nLogicX_B, nLogicY_B)

	local nDistanceX = nLogicX_A - nLogicX_B
	local nDistanceY = nLogicY_A - nLogicY_B
	
	return math.sqrt((nDistanceY * nDistanceY) + (nDistanceX * nDistanceX))
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