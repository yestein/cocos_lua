--=======================================================================
-- File Name    : skill_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/27 10:55:26
-- Description  : manage all skill script in games
-- Modify       : 
--=======================================================================

if not Skill then
	Skill = {
		template_data = {},
		skill_data = {},
	}
end

--SKILL TEMPLATE
function Skill:AddTemplate(template_id, cast_type, target_type, target_camp, effect_list)
 	local template = self.template_data[template_id]
 	if not template then
	 	self.template_data[template_id] = {
	 		cast_type = cast_type,
	 		target_type = target_type,
	 		target_camp = target_camp,
	 		effect_list = effect_list,
	 	}
	 else	 	
 		template.cast_type = cast_type
 		template.target_type = target_type
 		template.target_camp = target_camp
 		template.effect_list = effect_list
	 end
 end

function Skill:GetTemplate(template_id)
	local skill_template = self.skill_template_list[template_id]
	if not skill_template then
		assert(false, "No Skill Template[%d]!!", template_id)
		return
	end
	return skill_template
end


function Skill:AddData(skill_id, template_id, icon, level_data)
	local skill_data = self.skill_data[skill_id]
 	if not skill_data then
	 	self.skill_data[skill_id] = {
	 		icon        = icon,
			template_id = template_id,			
			level_data  = level_data,
	 	}
	 else	 	
		skill_data.icon        = icon
		skill_data.template_id = template_id
		skill_data.level_data  = level_data
	 end
end

function Skill:ConvertTime2Frame()
	for _, skill_data in pairs(self.skill_data) do
		local level_data = skill_data.level_data
		for level, param in pairs(level_data) do
			if param.cd_time then
				param.cd_time = math.ceil(param.cd_time * Def.GAME_FPS)
			end
		end
	end
end

function Skill:GetData(skill_id)
	if not self.skill_data[skill_id] then
		assert(false, "No Skill[%s] data!!", tostring(skill_id))
		return
	end
	return self.skill_data[skill_id]
end

function Skill:GetTemplateId(skill_id)
	local raw_data = self:GetData(skill_id)
	if not raw_data then
		return
	end
	return raw_data.template_id
end

function Skill:GetIcon(skill_id)
	local raw_data = self:GetData(skill_id)
	if not raw_data then
		return
	end
	return raw_data.icon
end

function Skill:GetLevelParam(skill_id, level)
	local raw_data = self:GetData(skill_id)
	if not raw_data then
		assert(false, "No Skill[%s]", tostring(skill_id))
		return
	end
	if not raw_data.level_data[level] then
		assert(false, "No Skill[%s] Level[%s]", tostring(skill_id), tostring(level))
		return
	end
	return raw_data.level_data[level]
end

local function InitSkill()
	if not Skill.template_data then
		return 0
	end
	Skill.skill_template_list = {}
	for template_id, data in pairs(Skill.template_data) do
		local skill_template = NewSkillTemplate(template_id)
		skill_template:Init(template_id, data.target_type, data.cast_type, data.target_camp, data.effect_list)
		Skill.skill_template_list[template_id] = skill_template
	end

	Skill:ConvertTime2Frame()
	return 1
end

AddInitFunction("Skill Init", InitSkill)
