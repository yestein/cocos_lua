--=======================================================================
-- File Name    : game_mgr_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun Mar 30 20:16:19 2014
-- Description  :
-- Modify       :
--=======================================================================

if not GameMgr then
	GameMgr = NewLogicNode("GOD")
end

local MAX_COLLECT_TIME = 20

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
	self.is_pause = 0
	self.is_movie_mode = 0

	self:SetFPS(Def.DEFAULT_FPS)
	assert(Movie:Init(100) == 1)
	assert(RealTimer:Init() == 1)

	assert(LogicTimer:Init() == 1)
	assert(GM:Init() == 1)
	assert(SpriteSheets:Init() == 1)
	assert(EffectMgr:Init() == 1)
	return self:_Init()
end

function GameMgr:OnLoop(delta)
	self.accumulate = self.accumulate + delta
	if self.accumulate > self.TIME_PER_FRAME then
		if self.is_pause ~= 1 then
			self.num_frame = self.num_frame + 1
			self:OnActive(self.num_frame)
			LogicTimer:OnActive()
		else
			if self:IsMovieMode() == 1 then
				self:OnMovieActive()
			end
		end
		if not self._lua_memory_count then
			self._lua_memory_count = collectgarbage("count")
			self.size = self._lua_memory_count / (MAX_COLLECT_TIME * self.LOGIC_FPS)
		end
		local result = collectgarbage("step", self.size)
		if result == true then
			self._lua_memory_count = nil
		end
		RealTimer:OnActive()
		self.accumulate = self.accumulate - self.TIME_PER_FRAME
	end	
end

function GameMgr:GetCurrentFrame()
	return self.num_frame
end

function GameMgr:OnMovieActive()
	if self._OnMovieActive then
		self:_OnMovieActive()
	end
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
end

function GameMgr:Pause(is_pause, ...)
	if self.is_pause == is_pause then
		return
	end
	self.is_pause = is_pause
	Event:FireEvent("GAME_PAUSE", self.is_pause, ...)
end

function GameMgr:IsPause()
	return self.is_pause
end

function GameMgr:IsMovieMode()
	return self.is_movie_mode
end

function GameMgr:SetMovieMode(is_movie)
	self.is_movie_mode = is_movie
end