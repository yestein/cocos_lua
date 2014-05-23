--=======================================================================
-- File Name    : skelton.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/22 14:38:42
-- Description  : skelton extend API
-- Modify       : 
--=======================================================================
require("framework/cocos2d/skelton.lua")

function Skelton:MoveTo(target_x, target_y, during_time)
	local x, y = self.armature:getPosition()
	local function playStop()
		if self:GetCurrentAnimation() == "run" then
			self:PlayAnimation("normal")
		end
	end
	if self:GetCurrentAnimation() ~= "run" then
		self:PlayAnimation("run")
	end
	local move_action = cc.MoveBy:create(during_time, cc.p(target_x - x, target_y - y))
	local play_stop = cc.CallFunc:create(playStop)
	self.armature:stopAllActions()
	self.armature:runAction(cc.Sequence:create(move_action, play_stop))
end

