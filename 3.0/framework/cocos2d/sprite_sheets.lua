--=======================================================================
-- File Name    : SpriteSheets.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/11 10:15:28
-- Description  : animation
-- Modify       : 
--=======================================================================

if not SpriteSheets then
	SpriteSheets = {}
end
local cache = cc.SpriteFrameCache:getInstance()

function SpriteSheets:Uninit()
	self.animation_num_list = nil
end

function SpriteSheets:Init()
	self.animation_num_list = {}
end

function SpriteSheets:SetAnimationParam(animation_name, param)
	self.animation_num_list[animation_name] = {frame_count = param.frame_count, time_interval = param.time_interval}
end

function SpriteSheets:GetAnimationParam(animation_name)
	return self.animation_num_list[animation_name]
end

function SpriteSheets:GetAnimationCount(animation_name)
	local param = self:GetAnimationParam(animation_name)
	if not param then
        assert(false, "No Animation[%s] Count", animation_name)
		return
	end

	return param.frame_count
end

function SpriteSheets:GetAnimationInterval(animation_name)
	local param = self:GetAnimationParam(animation_name)
	if not param then
		return
	end

	return param.time_interval
end


function SpriteSheets:RunAnimation(sprite, animation_name, time_interval)
	local frames = {}
	local frame_count = self:GetAnimationCount(animation_name)
    for i = 1, frame_count do 
        frames[i] = cache:getSpriteFrame(string.format("%s%d.png", animation_name, i))
        assert(frames[i])
    end
    if not time_interval then
    	time_interval = self:GetAnimationInterval(animation_name)
    end
    local animation = cc.Animation:createWithSpriteFrames(frames, time_interval)
    local action = cc.RepeatForever:create(cc.Animate:create(animation))
    sprite:stopAllActions()
    sprite:runAction(action)
end

function SpriteSheets:RunOneTimeAnimation(sprite, animation_name, time_interval)
	local frames = {}
	local frame_count = self:GetAnimationCount(animation_name)
    for i = 1, frame_count do 
        frames[i] = cache:getSpriteFrame(string.format("%s%d.png", animation_name, i))
        assert(frames[i], "%s %d", animation_name, i)
    end
    if not time_interval then
    	time_interval = self:GetAnimationInterval(animation_name)
    end
    local animation = cc.Animation:createWithSpriteFrames(frames, time_interval)
    local action = cc.Sequence:create(cc.Animate:create(animation), cc.RemoveSelf:create())
    sprite:stopAllActions()
    sprite:runAction(action)
end