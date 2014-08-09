--=======================================================================
-- File Name    : particles.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/11 14:48:43
-- Description  : particles system
-- Modify       : 
--=======================================================================

if not Particles then
	Particles = {}
end

function Particles:CreateParticles(particles_name)
	--TODO improve draw effects
	local file_name = Resource:GetParticlesFile(particles_name)
	local particles = cc.ParticleSystemQuad:create(file_name)
	return particles
end
