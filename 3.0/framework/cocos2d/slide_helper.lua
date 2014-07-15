--=======================================================================
-- File Name    : slide_helper.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/14 14:48:26
-- Description  : slide objects together
-- Modify       : 
--=======================================================================
if not SlideHelper then
	SlideHelper = NewLogicNode("Slide")
end

function SlideHelper:_Unnit()
	self.timer_id = nil
	self.is_working = nil
	self.container = nil
end

function SlideHelper:_Init()
	self.container = {}
	self.is_working = 0
	self.timer_id = nil
end

function SlideHelper:IsWorking()
	return self.is_working
end

function SlideHelper:Start(lasts_time)
	if self.timer_id then
		return 0
	end
	self.is_working = 1
	self:Clear()
	self.timer_id = RealTimer:RegistTimer(lasts_time * GameMgr:GetFPS(), {self.OnTimerEnd, self})
	Event:FireEvent("SLIDE.START", lasts_time)
end

function SlideHelper:OnTimerEnd(timer_id)
	self.timer_id = nil
	self:End()	
end

function SlideHelper:End()
	if self.timer_id then
		RealTimer:CloseTimer(self.timer_id)
		self.timer_id = nil
	end
	Event:FireEvent("SLIDE.END", self, self.last_x, self.last_y)
	self:Clear()
	self.is_working = 0
end

function SlideHelper:AddSprite(id, sprite)
	self.container[id] = sprite
end

function SlideHelper:RemoveSprite(id, sprite)
	self.container[id] = nil
end

function SlideHelper:OnMove(x, y)
	if self.last_x and self.last_y then
		local move_x = x - self.last_x
		local move_y = y - self.last_y
		for id, sprite in pairs(self.container) do
			local raw_x, raw_y = sprite:getPosition()
			--local new_x, new_y = raw_x + move_x, raw_y + move_y
			local new_x, new_y = x, y - 60
			sprite:setPosition(new_x, new_y)
			Event:FireEvent("SLIDE.MOVE", id, new_x, new_y)
		end
	end
	self.last_x = x
	self.last_y = y
end

function SlideHelper:GetAllSprites()
	return self.container
end

function SlideHelper:Clear()
	self.container = {}
	self.last_x = nil
	self.last_y = nil
end