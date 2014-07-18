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
	self.offset_y = nil
	self.offset_x = nil
end

function SlideHelper:_Init(is_drag, offset_x, offset_y)
	self.is_drag = is_drag or 0
	self.offset_x = offset_x or 0
	self.offset_y = offset_y or 0
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
	local end_x = self.last_x and self.last_x + self.offset_x
	local end_y = self.last_y and self.last_y + self.offset_y
	Event:FireEvent("SLIDE.END", self, end_x, end_y)
	self:Clear()
	self.is_working = 0
end

function SlideHelper:AddSprite(id, sprite)
	self.container[id] = 1
end

function SlideHelper:RemoveSprite(id, sprite)
	self.container[id] = nil
end

function SlideHelper:OnMove(x, y)
	if self.last_x and self.last_y then
		if self.is_drag == 1 then
			for id, _ in pairs(self.container) do
				Event:FireEvent("SLIDE.MOVE_OBJ", id, x + self.offset_x, y + self.offset_y)
			end
		end
	end
	Event:FireEvent("SLIDE.MOVE", self.last_x, self.last_y, x, y)
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