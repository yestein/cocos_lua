--=======================================================================
-- File Name    : skill_cast.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/5 15:59:22
-- Description  : skill_cast
-- Modify       : 
--=======================================================================

if not SkillCast then
	SkillCast = {
		class_list = {},
	}
end

function SkillCast:NewMethod(method_name)
	assert(not self.class_list[method_name])
	self.class_list[method_name] = {}
	
	return self.class_list[method_name]
end

function SkillCast:RawGetMethod(method_name)
	if not self.class_list[method_name] then
		return
	end
	return self.class_list[method_name]
end

function SkillCast:GetMethod(method_name)
	local method = self:RawGetMethod(method_name)
	if not method then
		assert(false, "No Skill Cast Method[%s]", method_name)
		return
	end
	return Lib:GetReadOnly(method)
end