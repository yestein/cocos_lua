--=======================================================================
-- File Name    : EffectMgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/18 16:49:38
-- Description  : Manage Effects(Particles and SpriteSheets) in Game
-- Modify       : 
--=======================================================================
if not EffectMgr then
	EffectMgr = {}
end

function EffectMgr:Uninit()
	self.effect_list = nil
end

function EffectMgr:Init()
	self.effect_list = {}
end

function EffectMgr:LoadEffect(effect_name, effect_type)
	if self.effect_list[effect_name] then
		assert(false)
		return
	end
	self.effect_list[effect_name] = effect_type
end

function EffectMgr:GetEffectType(effect_name)
	return self.effect_list[effect_name]
end


local GenearteFuncion = {
	["particles"] = function(particles_name)
		return Particles:CreateParticles(particles_name)
	end,
	["sprite_sheets"] = function(animation_name, no_loop)
		local effect = cc.Sprite:create()
		if no_loop == 1 then
			SpriteSheets:RunAnimationNoLoop(effect, animation_name)
		else
			SpriteSheets:RunAnimation(effect, animation_name)
		end
		return effect
	end,
}

function EffectMgr:GenearteEffect(effect_name, no_loop)
	local effect_type = self:GetEffectType(effect_name)
	if not effect_type then
		assert(false, "No Effect[%s]", effect_name)
		return
	end
	local func = GenearteFuncion[effect_type]
	if not func then
		assert(false, "No Effect Type[%s]", effect_type)
		return
	end
	return func(effect_name, no_loop)
end

