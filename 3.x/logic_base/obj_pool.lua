--=======================================================================
-- File Name    : obj_pool.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2014-03-02 16:14:23
-- Description  :
-- Modify       :
--=======================================================================

if not ObjPool then
    ObjPool = Class:New()
end

function ObjPool:IsValid()
    if self.obj_pool then
        return 1
    end
    return 0
end

function ObjPool:_Uninit()
    for id, obj in pairs(self.obj_pool) do
        self:Remove(id)
    end
    self.obj_pool = nil
    self.next_id = nil
    return 1
end

function ObjPool:_Init(obj_name, is_recycle)
    self.obj_pool = {}
    self.next_id = 1
    self.obj_name = obj_name
    if is_recycle == 1 then
        self.is_recycle = 1
        self.recycle_id_list = {}
    end
    return 1
end

function ObjPool:GetNextId()
    local ret_id = self.next_id

    if self.is_recycle == 1 then
        local reserve_id_count = #self.recycle_id_list
        if reserve_id_count > 0 then
            ret_id = self.recycle_id_list[reserve_id_count]
        end
    end

    return ret_id
end

function ObjPool:UpdateNextId()
    if self.is_recycle == 1 then
        local reserve_id_count = #self.recycle_id_list
        if reserve_id_count > 0 then
            self.recycle_id_list[reserve_id_count] = nil
            return
        end
    end
    self.next_id = self.next_id + 1
    while (self.obj_pool[self.next_id]) do
        self.next_id = self.next_id + 1
    end
end

function ObjPool:Add(obj_template, ...)
    local id = self:GetNextId()
    local obj = Class:New(obj_template, self.obj_name)

    self.obj_pool[id] = obj
    if obj:Init(id, ...) == 1 then
        self:UpdateNextId()
        Event:FireEvent(self.obj_name..".ADD", id, ...)
        return obj, id
    else
        self.obj_pool[id] = nil
        cclog("Add Error")
    end
end

-- function ObjPool:AddById(obj_template, id, ...)
--     local obj = Class:New(obj_template)
--     if obj:Init(id, ...) == 1 then
--         self.obj_pool[id] = obj
--         Event:FireEvent(self.obj_name..".ADD", id, ...)
--         return obj, id
--     else
--         cclog("Add Error")
--     end
-- end

function ObjPool:Remove(id, ...)
    if not id or not self.obj_pool[id] then
        assert(false)
        return 0
    end

    Event:FireEvent(self.obj_name..".REMOVE", id, ...)
    self.obj_pool[id]:Uninit()
    self.obj_pool[id] = nil
    if self.is_recycle == 1 then
        self.recycle_id_list[#self.recycle_id_list + 1] = id
    end
    return 1
end

function ObjPool:GetById(id)
    if not id then
        return
    end
    return self.obj_pool[id]
end

function ObjPool:ResetId()
    self.next_id = 1
end

function ObjPool:RemoveAll(callback)
    for id, obj in pairs(self.obj_pool) do
        if callback then
            callback(id, obj)
        end
        self:Remove(id)
    end
end

function ObjPool:ForEach(callback, ...)
    if self.obj_pool then
        for id, obj in pairs(self.obj_pool) do
            local ret = callback(id, obj, ...)
            if ret == 0 then
                return
            end
        end
    end
end
