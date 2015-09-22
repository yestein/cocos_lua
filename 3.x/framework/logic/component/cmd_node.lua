--=======================================================================
-- File Name    : cmd_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/20 13:44:43
-- Description  : make a obj can receive command
-- Modify       :
--=======================================================================

local CmdNode = ComponentMgr:GetComponent("COMMAND")
if not CmdNode then
    CmdNode = ComponentMgr:CreateComponent("COMMAND")
end

CmdNode:DeclareHandleMsg("EXECUTE_CMD", "Breath")

function CmdNode:_Uninit( ... )
    self.command_pool = nil
    return 1
end

function CmdNode:_Init( ... )
    self.command_pool = {}
    return 1
end

function CmdNode:Breath(frame)

    local cmd_frame, command = self:GetNextCommand()
    local fun = Stat:GetStatFunc("cmd active")
    while cmd_frame and cmd_frame <= frame do
        table.remove(self.command_pool, 1)
        self:Execute(command)
        cmd_frame, command = self:GetNextCommand()
    end
    if fun then
        fun()
    end
end

function CmdNode:GetNextCommand()
    local command_data = self.command_pool[1]
    if not command_data then
        return
    end
    return command_data[1], command_data[2]
end

function CmdNode:InsertCommand(command, delay_frame, priority)
    if not delay_frame then
        delay_frame = 0
    end

    local frame = GameMgr:GetCurrentFrame() + delay_frame

    table.insert(self.command_pool, {frame, command, priority or 0})
    table.sort(self.command_pool,
        function(a, b)
            if a[1] == b[1] then
                return a[3] > b[3]
            else
                return a[1] < b[1]
            end
        end
    )
    Event:FireEvent("RECEIVE_CMD", self:GetParent():GetId(), command[1], command, delay_frame)
    return frame
end

function CmdNode:RemoveCommand(index)
    Event:FireEvent("CANCEL_CMD", self:GetParent():GetId(), index)
    table.remove(self.command_pool, index)
end

function CmdNode:RemoveAllCmd()
    self.command_pool = {}
end

function CmdNode:Execute(command)
    Event:FireEvent("EXECUTE_CMD", self:GetParent():GetId(), command[1], unpack(command, 2))
    local func_name = command[1]
    local parent_obj = self:GetParent()
    parent_obj:TryCall(func_name, unpack(command, 2))
end
