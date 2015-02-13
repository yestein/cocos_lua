--=======================================================================
-- File Name    : buff_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/16 14:32:43
-- Description  : buff base class
-- Modify       : 
--=======================================================================
if not BuffBase then
	BuffBase = Class:New(nil, "BUFF_BASE")
end

function BuffBase:_Uninit()
	self.count = 1
	self.template_id = nil
	self.id = nil

	return 1
end

function BuffBase:_Init(id, owner, config)
	self.id = id
	self.template_id = config.template_id
	self.owner = owner
	self.count = 0
	self.max_count = config.max_count
	self.born_frame = GameMgr:GetCurrentFrame()

	--self.luancher = nil
	return 1
end

function BuffBase:GetBornFrame()
	return self.born_frame
end

function BuffBase:SetOwner(owner)
	self.owner = owner
end

function BuffBase:GetOwner()
	return self.owner
end

function BuffBase:SetLuancher(luancher)
	self.luancher = luancher
end

function BuffBase:GetLuancher()
	return self.luancher
end

function BuffBase:ChangeCount(change)
	local new_count = self.count + change
	if new_count < 0 then
		new_count = 0
	elseif new_count > self.max_count then
		new_count = self.max_count
	end
	if change > 0 then
		local config = BuffMgr:GetBuffConfig(self.id)
		if config.lasts_time and config.lasts_time > 0 then
			self:ResetLastsTime(config.lasts_time)
		end
	end
	if self.count == new_count then
		return 0
	end

	if self.OnChangeCount then
		self:OnChangeCount(self.count, new_count)
	end
	self.count = new_count
	return 1
end

function BuffBase:GetRestFrame()
	if self.remove_frame then
		return self.remove_frame - GameMgr:GetCurrentFrame()
	end
	return -1
end

function BuffBase:ResetLastsTime(lasts_time)
	if not lasts_time or lasts_time <= 0 then
		assert(false)
		return
	end
	local frame = math.ceil(lasts_time * GameMgr:GetFPS())
	self.remove_frame = GameMgr:GetCurrentFrame() + frame
end

function BuffBase:GetCount(count)
	return self.count
end

function BuffBase:OnActive(frame)
	local is_need_remove = 0
	if self.remove_frame and frame == self.remove_frame then
		is_need_remove = 1
	end
	if self._OnActive then
		self:_OnActive(frame)
	end
	return is_need_remove
end