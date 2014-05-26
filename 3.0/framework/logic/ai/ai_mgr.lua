--=======================================================================
-- File Name    : ai_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/26 16:26:48
-- Description  : manage all ai script in games
-- Modify       : 
--=======================================================================
if not AI then
	AI = {
		ai_pool = {},
	}
end

function AI:New(ai_name)
	if not self.ai_pool[ai_name] then
		self.ai_pool[ai_name] = {}
	end
	return self.ai_pool[ai_name]
end

function AI:GetClass(ai_name)
	return self.ai_pool[ai_name]
end