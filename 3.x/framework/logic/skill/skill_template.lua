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

function NewSkillTemplate(template_id, effect_list)
	local data = Skill:GetTemplateData(template_id)
	if not data then
		return
	end
	local skill = Class:New(SkillTemplate, template_id)
	skill:Init(template_id, data.target_type, data.cast_type, data.target_camp, effect_list)
	return skill
end

function SkillTemplate:_Init(template_id, target_type, cast_type, target_camp, effect_list)
	if not effect_list then
		effect_list = {}
	end
	self.template_id = template_id
	self.cast_method = SkillCast:GetMethod(cast_type)
	if not self.cast_method then
		return 0
	end
	self.target_type = target_type
	self.camp_judge_func = self.CAMP_FUNC[target_camp]
	if not self.camp_judge_func then
		return 0
	end
	self.effect_list = {}
	for _, effect_name in ipairs(effect_list) do
		table.insert(self.effect_list, SkillEffect:GetEffect(effect_name))
	end
	return 1
end

function SkillTemplate:SearchTarget(luancher, skill_param)
	local func = self.TARGET_FUNC[self.target_type]
	if not func then
		return
	end
	return func(self, luancher, skill_param)
end

function SkillTemplate:IsTargetValid(luancher, target, skill_param)
	if not target then
		return 0
	end
	if self.camp_judge_func(luancher, target) ~= 1 then
		return 0
	end

	if self.cast_method.IsTargetValid then
		return self.cast_method:IsTargetValid(luancher, target, skill_param)
	end
	return 1
end

function SkillTemplate:CanCast(luancher, target_list, skill_param)
	if target_list then
		for _, target_id in ipairs(target_list) do
			local target = CharacterPool:GetById(target_id)
			if self:IsTargetValid(luancher, target, skill_param) ~= 1 then
				return 0, "target invalid"
			end
		end
	end
	if self.cast_method.CanExecute then
		return self.cast_method:CanExecute(luancher, target_list, skill_param)
	end

	return 1
end

function SkillTemplate:Cast(luancher, target_list, skill_param)
	return self.cast_method:Execute(luancher, target_list, self, skill_param)
end

function SkillTemplate:ProduceEffect(luancher, target, param)
	if self.camp_judge_func(luancher, target) ~= 1 then
		return 0
	end
	Event:FireEvent("SKILL.PRODUCE_EFFECT", param.skill_id, luancher:GetId(), target:GetId(), param)
	for _, effect in ipairs(self.effect_list) do
		effect:Execute(luancher, target, param)
	end
	return 1
end

function SkillTemplate:SetTargetFunc(target_type, func)
	self.TARGET_FUNC[target_type] = func
end

function SkillTemplate:SetCampFunc(camp_type, func)
	self.CAMP_FUNC[camp_type] = func
end

-- SkillTemplate:SetCampFunc(
-- 	camp_type, 
-- 	function(luancher, target)
-- 	end
--)

-- SkillTemplate:SetTargetFunc(
-- 	target_type,
-- 	function(luancher, skill_param)
-- 	end
-- )