--=======================================================================
-- File Name    : skill_effect.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/29 15:10:47
-- Description  : skill effect
-- Modify       :
--=======================================================================

if not SkillEffect then
    SkillEffect = {
        class_list = {},
    }
end

function SkillEffect:NewEffect(effect_name)
    assert(not self.class_list[effect_name])
    self.class_list[effect_name] = {effect_name = effect_name}

    return self.class_list[effect_name]
end

function SkillEffect:RawGetEffect(effect_name)
    if not self.class_list[effect_name] then
        return
    end
    return self.class_list[effect_name]
end

function SkillEffect:GetEffect(effect_id, param)
    local effect_name = Def.SKILL_EFFECT_LIST[effect_id]
    local effect = self:RawGetEffect(effect_name)
    if not effect then
        assert(false, "No Skill Effect[%s]", effect_name)
        return
    end
    local new_effect = Class:New(effect, effect_name)
    new_effect.param = param
    return new_effect
end
