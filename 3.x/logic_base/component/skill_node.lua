--=======================================================================
-- File Name    : skill_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/7/30 11:28:35
-- Description  : description
-- Modify       :
--=======================================================================
local SkillNode = ComponentMgr:GetComponent("SKILL")
if not SkillNode then
    SkillNode = ComponentMgr:CreateComponent("SKILL")
end

SkillNode.forbid_skill_state = {}
function SkillNode:SetForbidState(key, value)
    self.forbid_skill_state[key] = value
end

function SkillNode:_Uninit( ... )
    self.current_skill_info = nil
    self.owned_skills       = nil

    self.is_critical      = nil
    self.next_skill_index = nil
    self.skills_index     = nil
    self.skills           = nil
    self.current_skill_info = nil
    self.target_list      = nil

    return 1
end

function SkillNode:_Init()
    self.owned_skills       = {}
    self.current_skill_info = {}

    self.target_list           = nil

    self.skills_index          = {}
    self.next_skill_index      = 1
    self.is_critical           = 0

    self:AddComponent("cd", "COOL_DOWN")

    return 1
end

function SkillNode:AddSkill(skill_id, skill_level, is_start_cd, skill_cd_time)
    assert(not self.owned_skills[skill_id])
    return self:_AddSkill(skill_id, skill_level, is_start_cd, skill_cd_time)
end

function SkillNode:_AddSkill(skill_id, skill_level, is_start_cd, skill_cd_time)
    if self.owned_skills[skill_id] then
        return
    end

    local data = Skill:GetData(skill_id)
    local skill_param = Lib:CopyTB1(Skill:GetLevelParam(skill_id, skill_level))
    if not data or not skill_param then
        assert(false)
        return 0
    end

    local skill_class = NewSkillTemplate(skill_id, data.target_type, data.cast_type, data.target_camp, skill_param)
    self.owned_skills[skill_id] = skill_class
    if skill_cd_time then
        skill_param.cd_time = math.floor(skill_cd_time * Def.GAME_FPS)
    end
    self:GetChild("cd"):Add(skill_id, (skill_param.cd_time or 2))
    if is_start_cd ~= 1 then
        self:GetChild("cd"):StartCD(skill_id)
    end
end

function SkillNode:RemoveSkill(skill_id)
    self.owned_skills[skill_id] = nil
    self:GetChild("cd"):Remove(skill_id)
end

function SkillNode:GetSkillClass(skill_id)
    return self.owned_skills[skill_id]
end

function SkillNode:GetSkillList()
    return self.owned_skills
end

function SkillNode:SetCurrentSkillInfo(skill_info)
    self.current_skill_info = skill_info
end

function SkillNode:GetCurrentSkillInfo()
    return self.current_skill_info
end

function SkillNode:SetTargetList(target_list)
    self.target_list = target_list
end

function SkillNode:GetTargetList()
    return self.target_list
end

function SkillNode:GetSkillRestCDTime(skill_id)

    local skill = self:GetSkillClass(skill_id)
    if not skill then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end

    local cd_node = self:GetChild("cd")
    return cd_node:GetRestCDTime(skill_id)
end
function SkillNode:GetSkillCDTime(skill_id)
    local skill = self:GetSkillClass(skill_id)
    if not skill then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end

    local cd_node = self:GetChild("cd")
    return cd_node:GetCDTime(skill_id, cd_time)
end

function SkillNode:SetSkillCDTime(skill_id, cd_time)
    local skill = self:GetSkillClass(skill_id)
    if not skill then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end

    local cd_node = self:GetChild("cd")
    return cd_node:SetCDTime(skill_id, cd_time)
end

function SkillNode:CanCastSkill(skill_id, target_list, ...)

    local skill_class = self:GetSkillClass(skill_id)
    if not skill_class then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end

    if not target_list then
        return 0, "no target"
    end

    local owner = self:GetParent()
    if owner:TryCall("GetState") == Def.STATE_DEAD then
        return 0, "dead"
    end

    local can_cast_skill = 1
    for state, _ in pairs(self.forbid_skill_state) do
        if owner:TryCall("GetBuffState", state) then
            can_cast_skill = 0
            break
        end
    end

    if can_cast_skill ~= 1 then
        return 0, "state"
    end
    if __SERVER == 1 then
        local rest_frame = self:GetSkillRestCDTime(skill_id)
        if rest_frame > 0 then
            return 0, "cd"
        end
    end
    for _, target in ipairs(target_list) do
        if skill_class:CanCast(owner, target, ...) ~= 1 then
            return 0, "target invalid"
        end
    end

    return 1
end

function SkillNode:IsSkillTargetValid(skill_id, target)
    local skill_class = self:GetSkillClass(skill_id)
    if not skill_class then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end

    local owner = self:GetParent()
    return skill_class:IsTargetValid(owner, target)
end


function SkillNode:SearchTarget(skill_id, ...)
    local skill_class = self:GetSkillClass(skill_id)
    if not skill_class then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end
    local owner = self:GetParent()
    return skill_class:SearchTarget(owner, ...)
end

function SkillNode:CastSkill(skill_id, ...)
    local target_list = self:SearchTarget(skill_id)
    local can_cast_skill, reason = self:CanCastSkill(skill_id, target_list)
    if can_cast_skill ~= 1 then
        return can_cast_skill, reason
    end

    local owner = self:GetParent()

    local skill_class = self:GetSkillClass(skill_id)
    if not skill_class then
        assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
        return 0, "no skill"
    end
    self:GetChild("cd"):StartCD(skill_id)
    Event:FireEvent("SKILL.CAST", owner:GetId(), skill_id, target_list)
    skill_class:Cast(owner, target_list, ...)
    return 1
end

function SkillNode:DirectCastSkill(skill_id, target, ...)

    local owner = self:GetParent()

    local skill_class = self:GetSkillClass(skill_id)
    if not skill_class then
        assert(false, "Luancher Have No Skill[%s]  [%s]", tostring(skill_id), owner:GetId())
        return 0, "no skill"
    end
    self:GetChild("cd"):StartCD(skill_id)
    Event:FireEvent("SKILL.CAST", owner:GetId(), skill_id, target:GetId())
    skill_class:Cast(owner, target, ...)

    return 1
end
