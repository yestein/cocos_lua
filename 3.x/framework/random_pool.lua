--=======================================================================
-- File Name    : random_pool.lua
-- Creator      : abel (abel@koogame.com)
-- Date         : 2015-05-13 17:44:00
-- Description  :
-- Modify       :
--=======================================================================
if not RandomPool then
    RandomPool = Class:New()
end

function RandomPool:_Uninit()
    self.random_pool = nil
end

function RandomPool:_Init()
    self.random_pool = {}
end

function RandomPool:AddSkillRandomList(luancher_id, skill_id, random_list)

    if #random_list < 1 then
        return
    end

    if not self.random_pool[luancher_id] then
        self.random_pool[luancher_id] = {}
    end

    if not self.random_pool[luancher_id][skill_id] then
        self.random_pool[luancher_id][skill_id] = {}
    end

    table.insert(self.random_pool[luancher_id][skill_id], random_list)
end

function RandomPool:NextRandomList(luancher_id, type_id)

    local random_list = table.remove(self.random_pool[luancher_id][type_id], 1)

    return random_list
    
end

function RandomPool:GetRandom(luancher_id,type_id)
    if not self.random_pool then
        return -1
    end
    if not self.random_pool[luancher_id] then
        assert("false", "Not LuancherId")
        return 
    end

    if not self.random_pool[luancher_id][type_id] then
        assert("false", "Not Skill Or Buff")
        return 
    end

    if not self.random_pool[luancher_id][type_id][1]then
        assert("false", "Not Random List")
        return 
    end

    if not self.random_pool[luancher_id][type_id][1][1]then
        self:NextRandomList(luancher_id, type_id)
    end

    local random = table.remove(self.random_pool[luancher_id][type_id][1], 1)
    
    return random
end

function RandomPool:AddBuffRandomList(luancher_id, buff_id, random_list)
     if #random_list < 1 then
        return
    end

    if not self.random_pool[luancher_id] then
        self.random_pool[luancher_id] = {}
    end

    if not self.random_pool[luancher_id][buff_id] then
        self.random_pool[luancher_id][buff_id] = {}
    end

    table.insert(self.random_pool[luancher_id][buff_id], random_list)
end