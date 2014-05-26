--=======================================================================
-- File Name    : progress_bar.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/5/26 10:47:57
-- Description  : progress timer in Cocos2d-x
-- Modify       : 
--=======================================================================

if not ProgressBar then
	ProgressBar = {}
end

function ProgressBar:GenerateByFile(file_name, raw_percentage)
	local sprite = cc.Sprite:create(file_name)
	local hp = cc.ProgressTimer:create(sprite)
	hp:setPercentage(raw_percentage or 100)
	hp:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	hp:setMidpoint(cc.p(0, 0.5))
	hp:setBarChangeRate(cc.p(1, 0))
	return hp
end