--=======================================================================
-- File Name    : cmd_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/20 13:44:43
-- Description  : make a obj can receive command
-- Modify       : 
--=======================================================================

if not CmdNode then
	CmdNode = NewLogicNode("CMD")
end

function CmdNode:_Init( ... )
	self.command_pool = {}
	return 1
end

function CmdNode:_Uninit( ... )
	-- body
end

function CmdNode:OnActive(frame)
	local command_list = self.command_pool[frame]
	if not command_list then
		return
	end
	for _, command in ipairs(command_list) do
		self:Execute(command)
	end
	self.command_pool[frame] = nil
end

function CmdNode:InsertCommand(command, delay_frame)
	if not delay_frame then
		delay_frame = 0
	end

	if delay_frame <= 0 then
		self:Execute(command)
		return
	end

	local frame = GameMgr:GetCurrentFrame() + delay_frame
	if not self.command_pool[frame] then
		self.command_pool[frame] = {}
	end
	table.insert(self.command_pool[frame], command)
	Event:FireEvent("RECEIVE_CMD", command[1], command, delay_frame)
end

function CmdNode:Execute(command)
	Event:FireEvent("EXECUTE_CMD", command[1], unpack(command, 2))
	local func_name = command[1]
	local parent_obj = self:GetParent()
	parent_obj:TryCall(func_name, unpack(command, 2))	
end
