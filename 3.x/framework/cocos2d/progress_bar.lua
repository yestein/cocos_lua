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
	local progress_bar = cc.ProgressTimer:create(sprite)
	progress_bar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	progress_bar:setMidpoint(cc.p(0, 0.5))
	progress_bar:setBarChangeRate(cc.p(1, 0))
	progress_bar:setPercentage(raw_percentage or 100)
	return progress_bar
end