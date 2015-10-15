--=======================================================================
-- File Name    : buff_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/16 14:32:43
-- Description  : buff base class
-- Modify       :
--=======================================================================
if not BuffBase then
    -- BuffBase = Class:New(nil, "BUFF_BASE")
    BuffBase = Class:New(LogicNode, "BUFF_BASE")
end

function BuffBase:_Uninit()
    self.lasts_time = nil
    self.max_count = nil
    self.count = nil
    self.template_id = nil
    self.id = nil

    return 1
end

function BuffBase:_Init(id, owner, config)
    self.id = id
    self.template_id = config.template_id
    self.owner = owner
    self.count = 0
    self.lasts_time = config.lasts_time
    self.max_count = config.max_count

    self.luancher = nil
    return 1
end

function BuffBase:SetOwner(owner)
    self.owner = owner
end

function BuffBase:GetOwner()
    return self.owner
end

function BuffBase:SetLuancher(luancher)
    self.luancher = luancher
end

function BuffBase:GetLuancher()
    return self.luancher
end

function BuffBase:ChangeCount(change)
    local new_count = self.count + change
    if new_count < 0 then
        new_count = 0
    elseif new_count > self.max_count then
        new_count = self.max_count
    end
    if change > 0 then
        if self.lasts_time then
            self:ResetLastsTime(self.lasts_time)
        end
    end
    if self.count == new_count then
        return 0
    end

    if self.OnChangeCount then
        self:OnChangeCount(self.count, new_count)
    end
    self.count = new_count
    return 1
end

function BuffBase:GetRestFrame()
    return self.rest_frame or -1
end

function BuffBase:ResetLastsTime(lasts_time)
    if not lasts_time then
        return
    end
    self.rest_frame = math.ceil(lasts_time * GameMgr:GetFPS())
end

function BuffBase:SetCount(count)
    self.count = count or 0
end

function BuffBase:GetCount()
    return self.count
end

function BuffBase:OnActive(frame)
    if self._OnActive then
        self:_OnActive(frame)
    end
    if not self.rest_frame then
        return 0
    end
    local is_need_remove = 0
    self.rest_frame = self.rest_frame - 1
    if self.rest_frame <= 0 then
        is_need_remove = 1
    end
    return is_need_remove
end

function BuffBase:GetId()
    return self.id
end

function BuffBase:GetTemplateId()
    return self.template_id
end
