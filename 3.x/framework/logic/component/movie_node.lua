--=======================================================================
-- File Name    : movie_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/8/18 14:33:01
-- Description  : description
-- Modify       : 
--=======================================================================

local MovieNode = ComponentMgr:GetComponent("MOVIE")
if not MovieNode then
	MovieNode = ComponentMgr:CreateComponent("MOVIE")
end

function MovieNode:_Uninit()
	self.position = nil
	return 1
end

function MovieNode:_Init(position)
	self.position = position
	return 1
end

function MovieNode:OnTimer(call_back, timer_id)
	call_back()
	return nil
end

function MovieNode:MovieGoto(call_back, x, y, time)
	local owner = self:GetParent()
	local event_name = owner:GetClassName()..".MOVIE_MOVETO"

	Event:FireEvent(event_name, owner:GetId(), x, y, time)
	self:RegistRealTimer(math.ceil(time * GameMgr:GetFPS()), {self.OnTimer, self, call_back})
	if x > self.position.x then
		owner:SetDirection("right")
	elseif x < self.position.x then
		owner:SetDirection("left")
	end
	self.position.x = x
	self.position.y = y
end

function MovieNode:MovieSay(call_back, text, font_size, delay_time)
	local owner = self:GetParent()
	Event:FireEvent("SHOW_NORMAL_POPO", owner:GetId(), text, {font_size = font_size})
	local function OnTimerCallBack()
		call_back()
	end
	self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {self.OnTimer, self, call_back})
end

function MovieNode:MoviePlayAnimation(call_back, animation_name, is_loop, delay_time)
	local owner = self:GetParent()
	local event_name = owner:GetClassName()..".PLAY_ANIMATION"
	Event:FireEvent(event_name, owner:GetId(), animation_name, is_loop)
	self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {self.OnTimer, self, call_back})
end

function MovieNode:MovieDelay(call_back, delay_time)
	self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {self.OnTimer, self, call_back})
end
