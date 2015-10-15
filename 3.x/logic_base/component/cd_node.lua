--=======================================================================
-- File Name    : cd_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/16 11:00:37
-- Description  : record cool down
-- Modify       :
--=======================================================================

local CDNode = ComponentMgr:GetComponent("COOL_DOWN")
if not CDNode then
    CDNode = ComponentMgr:CreateComponent("COOL_DOWN")
end

function CDNode:_Uninit()
    self.last_used_frame = nil
    self.cd_time         = nil

    return 1
end

function CDNode:_Init()
    self.cd_time         = {}
    self.last_used_frame = {}

    return 1
end

function CDNode:Add(id, cd_time)
    self.cd_time[id] = cd_time
    self.last_used_frame[id] = -1
end

function CDNode:Remove(id)
    self.cd_time[id] = nil
    self.last_used_frame[id] = nil
end

function CDNode:SetCDTime(id, cd_time)
    self.cd_time[id] = cd_time
end

function CDNode:GetCDTime(id)
    return self.cd_time[id]
end

function CDNode:StartCD(id)
    if not self.last_used_frame[id] then
        return 0
    end
    self.last_used_frame[id] = GameMgr:GetCurrentFrame()
    return 1
end

function CDNode:InstantCoolDown(id)
    self.last_used_frame[id] = -1
end

function CDNode:GetList()
    return self.cd_time, self.last_used_frame
end

function CDNode:GetRestCDTime(id)
    local cd_frame = self.cd_time[id]
    local last_frame = self.last_used_frame[id]
    if last_frame == -1  then
        return 0
    end
    local current_frame = GameMgr:GetCurrentFrame()
    local past_frame = current_frame - last_frame
    if past_frame >= cd_frame then
        return 0
    end

    return cd_frame - past_frame, cd_frame
end

function CDNode:MinusLastUsedTime(id, minus_time)
    local last_frame = self.last_used_frame[id]
    if not last_frame or not minus_time then
        return
    end
    local new_last_frame = last_frame - (minus_time * GameMgr:GetFPS())
    if new_last_frame == 0 then
        new_last_frame = -1
    end
    self.last_used_frame[id] = new_last_frame
end
