--=======================================================================
-- File Name    : buff_effect_sample.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/28 18:09:20
-- Description  : buff_effect_sample
-- Modify       :
--=======================================================================
local EffectClass = SkillEffect:RawGetEffect("buff_effect_sample")
if not EffectClass then
    EffectClass = SkillEffect:NewEffect("buff_effect_sample")
end

function EffectClass:Execute(luancher, target, skill_id)

end
