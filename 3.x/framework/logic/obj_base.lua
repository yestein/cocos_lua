--=======================================================================
-- File Name    : obj_base.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         :
-- Description  :
-- Modify       :
--=======================================================================

if not ObjBase then
    ObjBase = NewLogicNode("OBJ")
end

function ObjBase:_Init(id)
    self.id = id

    return 1
end

function ObjBase:_Uninit()
    self.id = nil
    return 1
end

function ObjBase:GetId()
    return self.id
end

function ObjBase:FireEvent(event_name, ...)
    return Event:FireEvent(self:GetClassName().."."..event_name, self:GetId(), ...)
end
