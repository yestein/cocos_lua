--=======================================================================
-- File Name    : real_timer.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/1 20:41:20
-- Description  : real timer, no not effect by game pause
-- Modify       : 
--=======================================================================

if not RealTimer then
	RealTimer = Class:New(TimerBase, "RealTimer")
end