--=======================================================================
-- File Name    : skill_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/29 13:58:38
-- Description  : description
-- Modify       :
--=======================================================================

if not SkillTemplate then
    SkillTemplate = Class:New(nil, "SKILL_TEMPLATE")
end

SkillTemplate.CAMP_FUNC = {}
SkillTemplate.TARGET_FUNC = {}

function NewSkillTemplate(skill_id, target_type, cast_type, target_camp, level_param)
    local skill = Class:New(SkillTemplate, skill_id)
    skill:Init(skill_id, target_type, cast_type, target_camp, level_param)
    return skill
end

function SkillTemplate:_Init(skill_id, target_type, cast_type, target_camp, level_param)
    self.skill_id = skill_id
    self.cast_method = SkillCast:GetMethod(cast_type)
    if not self.cast_method then
        return 0
    end
    self.target_type = target_type
    self.target_camp = target_camp
    self.camp_judge_func = self.CAMP_FUNC[target_camp]
    if not self.camp_judge_func then
        return 0
    end
    self.effect_list = {}
    if level_param.effect_list then
        for _, effect_data in ipairs(level_param.effect_list) do
            local effect_id = effect_data.effect_id
            table.insert(self.effect_list, SkillEffect:GetEffect(effect_id, effect_data))
        end
    end
    self.raw_level_param = level_param
    self.level_param = Lib:GetReadOnly(level_param)
    return 1
end

function SkillTemplate:GetId()
    return self.skill_id
end

function SkillTemplate:SearchTarget(luancher)
    local func = self.TARGET_FUNC[self.target_type]
    if not func then
        return
    end
    return func(self, luancher, self.level_param)
end

function SkillTemplate:IsTargetValid(luancher, target)
    if not target then
        return 0
    end
    if self.camp_judge_func(luancher, target) ~= 1 then
        return 0
    end

    if self.cast_method.IsTargetValid then
        return self.cast_method:IsTargetValid(luancher, target, self.level_param)
    end
    return 1
end

function SkillTemplate:CanCast(luancher, target_list)
    if target_list then
        for _, target_id in ipairs(target_list) do
            local target = CharacterPool:GetById(target_id)
            if self:IsTargetValid(luancher, target, self.level_param) ~= 1 then
                return 0, "target invalid"
            end
        end
    end
    if self.cast_method.CanExecute then
        return self.cast_method:CanExecute(luancher, target_list, self.level_param)
    end

    return 1
end

function SkillTemplate:CriticalTest(owner)
    if not self.cast_method.CriticalTest then
        return 0
    end
    return self.cast_method:CriticalTest(owner, self.level_param)
end

function SkillTemplate:DodgeTest(owner)
    if not self.cast_method.DodgeTest then
        return 0
    end
    return self.cast_method:DodgeTest(owner, self.level_param)
end

function SkillTemplate:Cast(luancher, target_list, ...)
    return self.cast_method:Execute(luancher, target_list, self, self.level_param, ...)
end

function SkillTemplate:ProduceEffect(luancher, target, param)
    if self.camp_judge_func(luancher, target) ~= 1 then
        return 0
    end
    local skill_id = self:GetId()
    for _, effect in ipairs(self.effect_list) do
        effect:Execute(luancher, target, skill_id, param, 1)
    end
    return 1
end

function SkillTemplate:SetTargetFunc(target_type, func)
    self.TARGET_FUNC[target_type] = func
end

function SkillTemplate:SetCampFunc(camp_type, func)
    self.CAMP_FUNC[camp_type] = func
end
