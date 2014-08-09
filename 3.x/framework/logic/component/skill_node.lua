--=======================================================================
-- File Name    : skill.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/19 15:26:33
-- Description  : make obj can use skill
-- Modify       : 
--=======================================================================

local SkillNode = ComponentMgr:GetComponent("SKILL")
if not SkillNode then
	SkillNode = ComponentMgr:CreateComponent("SKILL")
end

local forbid_skill_state = {
	[Def.BUFF_SLEEP ]   = 1,
	[Def.BUFF_STUN  ]   = 1,
	[Def.BUFF_FREEZE]   = 1,
}

function SkillNode:_Uninit( ... )
	self.next_skill_index = nil
	self.skills_index     = nil
	self.skills           = nil
	self.current_skill_id = nil
	self.target_list      = nil

	return 1
end

function SkillNode:_Init()
	self.target_list           = nil
	self.current_skill_id      = 0
	self.skills                = {}
	self.skills_index          = {}
	self.next_skill_index      = 1

	self:AddComponent("cd", "COOL_DOWN")

	return 1
end

function SkillNode:AddSkill(skill_id, skill_level, index)
	assert(not self.skills[skill_id])	
	local data = Skill:GetData(skill_id)
	local template_id = Skill:GetTemplateId(skill_id)
	local skill_param = Lib:CopyTB1(Skill:GetLevelParam(skill_id, skill_level))
	if not template_id or not skill_param then
		assert(false)
		return 0
	end
	local skill_template = NewSkillTemplate(template_id, data.effect_list)
	skill_param.skill_id = skill_id
	self.skills[skill_id] = {skill_template = skill_template, skill_param = skill_param}
	if not index then
		index = self.next_skill_index
		self.next_skill_index = self.next_skill_index + 1
	end
	self.skills_index[index] = skill_id
	self:GetChild("cd"):Add(skill_id, (skill_param.cd_time or 0))
	self:GetChild("cd"):StartCD(skill_id)
end

function SkillNode:RemoveSkill(skill_id)	
	local remove_index = self:GetSkillIndex(skill_id)
	if not remove_index then
		assert(false, "Remove Skill [%s] Failed", tostring(skill_id))
		return
	end

	table.remove(remove_index)
	self.next_skill_index = self.next_skill_index - 1
	self.skills[skill_id] = nil
	self:GetChild("cd"):Remove(skill_id)
end

function SkillNode:GetSkillIndex(skill_id)
	local index = nil
	for i, id in pairs(self.skills_index) do
		if id == skill_id then
			index = i
			break
		end
	end
	return index
end

function SkillNode:GetSkillList()
	return self.skills
end

function SkillNode:SetCurrentSkillId(skill_id)
	self.current_skill_id = skill_id
end

function SkillNode:GetCurrentSkillId()
	return self.current_skill_id
end

function SkillNode:SetTargetList(target_list)
	self.target_list = target_list
end

function SkillNode:GetTargetList()
	return self.target_list
end

function SkillNode:GetSkillRestCDTime(skill_id)
	local skill = self.skills[skill_id]
	if not skill then
		return 0
	end

	local cd_node = self:GetChild("cd")
	return cd_node:GetRestCDTime(skill_id)
end

function SkillNode:GetSkillRange(skill_id)
	local skill = self.skills[skill_id]
	if not skill then
		assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
		return 0, "no skill"
	end
	return skill.skill_param.range
end

function SkillNode:CanCastSkill(skill_id, target_list)
	local skill = self.skills[skill_id]
	if not skill then
		assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
		return 0, "no skill"
	end
	local owner = self:GetParent()
	if owner:IsInState(Def.STATE_DEAD) == 1 then
		return 0, "dead"
	end
	local can_cast_skill = 1
	for state, _ in pairs(forbid_skill_state) do
		if owner:TryCall("GetBuffState", state) then
			can_cast_skill = 0
			break
		end
	end
	if can_cast_skill ~= 1 then
		return 0, "buff"
	end
	local rest_frame = self:GetSkillRestCDTime(skill_id)
	if rest_frame > 0 then
		return 0, "cd"
	end
	return skill.skill_template:CanCast(owner, target_list, skill.skill_param)
end

function SkillNode:IsSkillTargetValid(skill_id, target)
	local skill = self.skills[skill_id]
	if not skill then
		assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
		return
	end
	local owner = self:GetParent()
	return skill.skill_template:IsTargetValid(owner, target, skill.skill_param)
end

function SkillNode:SearchTarget(skill_id)
	local skill = self.skills[skill_id]
	if not skill then
		assert(false, "Luancher Have No Skill[%s]", tostring(skill_id))
		return 0, "no skill"
	end
	local owner = self:GetParent()
	return skill.skill_template:SearchTarget(owner, skill.skill_param)
end

function SkillNode:CastSkill(skill_id, is_force)
	local target_list = self:SearchTarget(skill_id)
	local can_cast_skill, reason = self:CanCastSkill(skill_id, target_list)
	if can_cast_skill ~= 1 then
		return can_cast_skill, reason
	end
	local owner = self:GetParent()
	if owner:TryCall("Stop") ~= 1 then
		return 0, "can not stop"
	end
	if owner:TryCall("SetActionState", Def.STATE_SKILL) ~= 1 then
		return 0, "state error"
	end
	self:GetChild("cd"):StartCD(skill_id)
	self:SetTargetList(target_list)
	self:SetCurrentSkillId(skill_id)
		
	local event_name = owner:GetClassName()..".CAST_SKILL"
	Event:FireEvent(event_name, self:GetParent():GetId(), skill_id, is_force)
	return 1
end

function SkillNode:HitCallback()
	local skill_id = self:GetCurrentSkillId()
	if not skill_id or skill_id == 0 then
		return
	end
	local target_list = self:GetTargetList()
	local skill = self.skills[skill_id]
	if not skill then
		return
	end
	local owner = self:GetParent()
	skill.skill_template:Cast(owner, target_list, skill.skill_param)
end