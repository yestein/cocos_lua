--=======================================================================
-- File Name    : skill_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/27 10:55:26
-- Description  : manage all skill script in games
-- Modify       : 
--=======================================================================

if not SkillMgr then
	SkillMgr = {
		skill_pool = {},
	}
end

function SkillMgr:New(skill_name)
	if not self.skill_pool[skill_name] then
		self.skill_pool[skill_name] = {}
	end
	return self.skill_pool[skill_name]
end

function SkillMgr:GetSkill(skill_name)
	local skill = self.skill_pool[skill_name]
	if skill then
		return Lib:GetReadOnly(skill)
	end
end