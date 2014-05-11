--=======================================================================
-- File Name    : gm.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun May 11 22:28:16 2014
-- Description  :
-- Modify       :
--=======================================================================

if not GM then
	GM = ModuleMgr:NewModule("GM")
end

function GM:_Init()
	self.actions = {}
end

function GM:_Uninit()
end

function GM:RecieveEvent(event_type, action_list)
	for _, action in ipairs(action_list) do
		self:ExecuteAction(action[1], unpack(action, 2))
	end
end

function GM:ExecuteAction(action_name, ...)
	local func = self.actions[action_name]
	assert(func)
	func(...)
end

function GM:AddAction(action_name, func)
	if not self.actions[action_name] then
		print(action_name)
	end
	assert(not self.actions[action_name])
	self.actions[action_name] = func
end

function GM:ParseEventData(event_handle)
	for event_type, action_list in pairs(event_handle) do
		local function_name = "On"..event_type	
		GM[function_name] = function(self)
			GM:RecieveEvent(event_type, action_list)
		end
		GM:DeclareListenEvent(event_type, function_name)
	end
end

