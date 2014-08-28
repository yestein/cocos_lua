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

function Lib:Show2DTB(tb, row, column, is_reverse)
	local title = "\t"
	if is_reverse ~= 1 then
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
	else
		for i = 1, row do
			title = title.."\t"..i
		end
		print(title)
		print("-----------------------------------------------------------------------------------------------")
		for i = 1, column do
			local msg = i.."\t|"
			if tb[column] then
				for j = 1, row do
					msg = msg .."\t"..tostring(tb[j][i])
				end
				print(msg)
			end
		end
	end
end

function Lib:CountTB(tb)
	local count = 0
	for k, v in pairs(tb) do
		count = count + 1
	end
	return count
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
		return callback[1](unpack(callback, 2))
	end
	return xpcall(InnerCall, Lib.ShowStack)
end

function Lib:MergeTable(table_dest, table_src)
	for _, v in ipairs(table_src) do
		table_dest[#table_dest + 1] = v
	end
end

function Lib:ShowTB(table_raw, n)
	if not table_raw then
		print("nil")
		return
	end
	if not n then
		n = 7
	end
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

function Lib:GetWritablePath()
	if not self.writeable_path then
		self.writeable_path = cc.FileUtils:getInstance():getWritablePath()
	end
	return self.writeable_path
end

function Lib:IsIntersects(x_1, y_1, width_1, height_1, x_2, y_2, width_2, height_2)
	local min_x_1 = x_1
	local max_x_1 = x_1 + width_1
	local min_y_1 = y_1
	local max_y_1 = y_1 + height_2
	
	local min_x_2 = x_2
	local max_x_2 = x_2 + width_2
	local min_y_2 = y_2
	local max_y_2 = y_2 + height_2

    if (max_x_1 < min_x_2) or (max_x_2 < min_x_1)
     or (max_y_1 < min_y_2) or (max_y_2 < min_y_1) then
     	return 0
    end

    return 1
end

function Lib:GetAngle(raw_angle, x_1, y_1, x_2, y_2)
	local delta_x = x_2 - x_1
	local delta_y = y_2 - y_1

	if delta_x == 0 and delta_y >= 0 then
		angle = 0
	elseif delta_x > 0 and delta_y > 0 then
		angle = math.deg(math.atan(delta_x / delta_y))
	elseif delta_x > 0 and delta_y == 0 then
		angle = 90
	elseif delta_x > 0 and delta_y < 0 then
		angle = 180 + math.deg(math.atan(delta_x / delta_y))
	elseif delta_x == 0 and delta_y < 0 then
		angle = 180
	elseif delta_x < 0 and delta_y < 0 then
		angle = 180 + math.deg(math.atan(delta_x / delta_y))
	elseif delta_x < 0 and delta_y == 0 then
		angle = 270
	elseif delta_x < 0 and delta_y > 0 then
		angle = 360 + math.deg(math.atan(delta_x / delta_y))
	end

	return angle - raw_angle
end

function Lib:Dijkstra(map, start_node, end_node)
	local node_info_list = {[start_node] = {value = 0, path = {}},}
	local U = {}
	for k, v in pairs(map) do
		if k ~= start_node then
			U[k] = 1
		end
	end
	local current_node = start_node
	local current_node_info = node_info_list[start_node]
	while Lib:CountTB(U) > 0 do
		local min_value = nil
		local nearest_node = nil
		for search_node, _ in pairs(U) do
			local value = map[current_node] and map[current_node][search_node] or nil
			if value then
				if not min_value or min_value > value then
					min_value = value
					nearest_node = search_node
				end
				local path = Lib:CopyTB1(current_node_info.path)
				table.insert(path, current_node)

				local search_node_info = node_info_list[search_node]
				if not search_node_info then
					node_info_list[search_node] = {
						value = current_node_info.value + value,
						path = path,
					}
				else
					if current_node_info.value + value < search_node_info.value then
						search_node_info.value = current_node_info.value + value
						search_node_info.path = path
					end
				end
			end
		end
		U[current_node] = nil
		for search_node, _ in pairs(U) do
			if node_info_list[search_node] then
				current_node = search_node
				current_node_info = node_info_list[search_node]
				break
			end
		end
	end
	return node_info_list
end

local connect_map = {
	wuzhishan   = {["wuzhishan_0"] = 1, ["wuzhishan_1"] = 1,},
	mkj         = {["wuzhishan_5"] = 1,},
	renshenguo  = {["wuzhishan_1"] = 1,},
	wuzhishan_0 = {["wuzhishan"] = 1, ["wuzhishan_4"] = 1,},
	wuzhishan_1 = {["renshenguo"] = 1, ["wuzhishan_5"] = 1, ["wuzhishan"] = 1, ["wuzhishan_4"] = 1,},
	wuzhishan_2 = {["wuzhishan_4"] = 1,},
	wuzhishan_3 = {["wuzhishan_4"] = 1,},
	wuzhishan_4 = {["wuzhishan_0"] = 1, ["wuzhishan_1"] = 1, ["wuzhishan_2"] = 1, ["wuzhishan_3"] = 1,},
	wuzhishan_5 = {["mkj"] = 1, ["wuzhishan_1"] = 1,},
}

local result = Lib:Dijkstra(connect_map, "wuzhishan_0")
Lib:ShowTB(result["mkj"].path)