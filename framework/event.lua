--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not Event then
	Event = {}
end

function Event:Preload()
	self.tbGlobalEvent = {}
end

function Event:RegistWatcher(tbBlackEventList, fnCallBack)
	self.tbEventBlackList = tbBlackEventList
	self.fnWatcherCallBack = fnCallBack
end

function Event:RegistEvent(szEvent, fnCallBack, ...)
	if not szEvent or not fnCallBack then
		assert(false)
		return
	end
	if not self.tbGlobalEvent[szEvent] then
		self.tbGlobalEvent[szEvent] = {}
	end
	local tbCallBack = self.tbGlobalEvent[szEvent]
	local nRegisterId = #tbCallBack + 1
	tbCallBack[nRegisterId] = {fnCallBack, {...}}
	return nRegisterId
end

function Event:UnRegistEvent(szEvent, nRegisterId)
	if not szEvent or not nRegisterId then
		assert(false)
		return
	end
	if not self.tbGlobalEvent[szEvent] then
		return 0
	end
	local tbCallBack = self.tbGlobalEvent[szEvent]
	if not tbCallBack[nRegisterId] then
		return 0
	end
	tbCallBack[nRegisterId] = nil
	return 1
end

function Event:FireEvent(szEvent, ...)
	self:CallBack(self.tbGlobalEvent[szEvent], ...)
	if self.fnWatcherCallBack then
		if not self.tbEventBlackList or not self.tbEventBlackList[szEvent] then
			self.fnWatcherCallBack(szEvent, ...)
		end
	end
end


function Event:CallBack(tbEvent, ...)
	if not tbEvent then
		return
	end
	local tbCopyEvent = Lib:CopyTB1(tbEvent)
	for nRegisterId, tbCallFunc in pairs(tbCopyEvent) do
		if tbEvent[nRegisterId] then
			local fnCallBack = tbCallFunc[1]
			local tbPackArg = tbCallFunc[2]

			if #tbPackArg > 0 then
				Lib:SafeCall({fnCallBack, unpack(tbPackArg), ...})
			else
				Lib:SafeCall({fnCallBack, ...})
			end
		end
	end
end