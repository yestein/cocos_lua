--=======================================================================
-- File Name    : puppet_pool.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/9/28 18:48:58
-- Description  : manage puppet
-- Modify       :
--=======================================================================
local PuppetPool = {}

function NewPuppetPool(scene_name, name)
    local pool = Class:New(PuppetPool, name)
    pool:Init(scene_name)
    return pool
end

function PuppetPool:_Uninit()
    for id, _ in pairs(self.puppet_list) do
        self:RemoveById(id)
    end
    self.puppet_list = nil
    self.scene = nil

    return 1
end

function PuppetPool:_Init(scene_name)
    self.scene = SceneMgr:GetScene(scene_name)
    self.puppet_list = {}
    return 1
end

function PuppetPool:Add(layer_name, id, puppet)
    assert(not self.puppet_list[id])
    if not puppet then
        return
    end
    puppet.id = id
    if layer_name then
        local sprite = puppet:GetSprite()
        self.scene:AddObj(layer_name, self:GetClassName(), id, sprite)
    end
    self.puppet_list[id] = {puppet, layer_name}
    return puppet
end

function PuppetPool:GetById(id)
    local one = self.puppet_list[id]
    if one then
        return unpack(one)
    end
end

function PuppetPool:ForEach(call_back, ...)
    if self.puppet_list then
        for id, obj in pairs(self.puppet_list) do
            local ret = call_back(id, obj[1], obj[2], ...)
            if ret == 0 then
                return
            end
        end
    end
end

function PuppetPool:RemoveById(id)
    local puppet, layer_name = self:GetById(id)
    if puppet then
        self.scene:RemoveObj(layer_name, self:GetClassName(), id, true)
        puppet:Uninit()
        self.puppet_list[id] = nil
    end
end
