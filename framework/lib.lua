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

function Lib:Reload()
	print("Lib:Reload")
	dofile("script/maze.lua")
	dofile("script/lib.lua")
	dofile("script/define.lua")
	dofile("script/hero.lua")
end

function Lib:GetLogicPosByPosition(nX, nY)
	local tbSize = Maze:GetSize()
	local nLogicX = math.floor(nX / Def.BLOCK_WIDTH)
	local nLogicY = math.floor(nY / Def.BLOCK_HEIGHT)

	nLogicX = nLogicX + Def.MAZE_LOGIC_WIDTH / 2 + 1
	nLogicY = nLogicY + math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) + 1
	return nLogicX, nLogicY
end

function Lib:GetPositionByLogicPos(nLogicX, nLogicY)
	local tbSize = Maze:GetSize()
	local nX = (nLogicX - Def.MAZE_LOGIC_WIDTH / 2 - 0.5) * Def.BLOCK_WIDTH
	local nY = (nLogicY - math.floor(tbSize.height / Def.BLOCK_HEIGHT / 2) - 0.5) * Def.BLOCK_HEIGHT
	
	return nX, nY
end

function Lib:IsHero(dwId)
	if dwId <= 100 then
		return 1
	else
		return 0
	end
end

function Lib:GetDistance(nLogicX_A, nLogicY_A, nLogicX_B, nLogicY_B)

	local nDistanceX = nLogicX_A - nLogicX_B
	local nDistanceY = nLogicY_A - nLogicY_B
	
	return math.sqrt((nDistanceY * nDistanceY) + (nDistanceX * nDistanceX))
end

function Lib:GetOppositeDirection(nDir)
	if nDir == Def.DIR_DOWN then
		return Def.DIR_UP
	elseif nDir == Def.DIR_RIGHT then
		return Def.DIR_LEFT
	elseif nDir == Def.DIR_LEFT then
		return Def.DIR_RIGHT
	elseif nDir == Def.DIR_UP then
		return Def.DIR_DOWN
	end
end

