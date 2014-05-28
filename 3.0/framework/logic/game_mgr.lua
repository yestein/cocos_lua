--=======================================================================
-- File Name    : game_mgr_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Mar 30 20:16:19 2014
-- Description  :
-- Modify       :
--=======================================================================

if not GameMgr then
	GameMgr = {}
end

function GameMgr:SetFPS(fps)
	self.LOGIC_FPS = fps
	self.TIME_PER_FRAME = 1 / fps
end

function GameMgr:GetFPS()
	return self.LOGIC_FPS
end

function GameMgr:Init()
	self.num_frame = 0
	self.accumulate = 0

	self:SetFPS(25)
	GM:Init()
	self:_Init()
end

function GameMgr:OnLoop(delta)
	self.accumulate = self.accumulate + delta
	if self.accumulate > self.TIME_PER_FRAME then
		self.num_frame = self.num_frame + 1
		self:OnActive(self.num_frame)
		self.accumulate = self.accumulate - self.TIME_PER_FRAME
	end	
end

function GameMgr:GetCurrentFrame()
	return self.num_frame
end

function GameMgr:OnActive(frame)
	if self._OnActive then
		self:_OnActive(frame)
	end
	ModuleMgr:ForEachActiveModule(
		function(module, func)
			func(module, frame)
		end
	)
	--TODO Garbage Collect!!!!
end