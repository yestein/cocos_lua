--=======================================================================
-- File Name    : skill_cast_sample.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/28 15:54:22
-- Description  : skill_cast_sample
-- Modify       :
--=======================================================================
local CastClass = SkillCast:RawGetMethod("cast_sample")
if not CastClass then
    CastClass = SkillCast:NewMethod("cast_sample")
end

function CastClass:IsTargetValid(luancher, target)
    return 1
end

function CastClass:CanExecute(luancher, target_list, skill_param)
    return 1
end

function CastClass:Execute(luancher, target_list, skill_template, skill_param)

end
