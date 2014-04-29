--=======================================================================
-- File Name    : fly_text.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2014/3/19 13:29:30
-- Description  : 
-- Modify       :
--=======================================================================

if not FlyText then
	FlyText = {}
end

function FlyText:RandomJumped(sprite, custom_font_path, text, param)
	if not param then
		param = {}
	end
	
	local jumped_text = cc.LabelBMFont:create(text, custom_font_path)
	if param.text_scale then
		jumped_text:setScale(param.text_scale)
	end
	local sprite_rect = sprite:getBoundingBox()
	local percent_x = param.percent_x or 0.5
	local percent_y = param.percent_y or 0.75
	jumped_text:setPosition(sprite_rect.width * percent_x, sprite_rect.height * percent_y)

	local color = param.color or "white"	
	jumped_text:setColor(Def:GetColor(color))
	sprite:addChild(jumped_text)

	local up_speed = param.up_speed or 800
	local up_min_x = param.up_min_x or 5
	local up_max_x = param.up_max_x or 40
	local up_min_y = param.up_min_y or 60
	local up_max_y = param.up_max_y or 100

	local function GenerateActionMoveUp(is_left)
		local distance_x = math.random(up_min_x, up_max_x)
		local distance_y = math.random(up_min_y, up_max_y)
		local time = distance_y / up_speed
		if is_left == 1 then
			return cc.MoveBy:create(time, cc.p(-distance_x, distance_y))
		else
			return cc.MoveBy:create(time, cc.p(distance_x, distance_y))
		end
	end

	local down_speed = param.down_speed or 600
	local down_min_x = param.down_min_x or 5
	local down_max_x = param.down_max_x or 10
	local down_min_y = param.down_min_y or 15
	local down_max_y = param.down_max_y or 25

	local function GenerateActionMoveDown(is_left)
		local distance_x = math.random(down_min_x, down_max_x)
		local distance_y = math.random(down_min_y, down_max_y)
		local time = distance_y / down_speed
		if is_left == 1 then
			return cc.MoveBy:create(time, cc.p(-distance_x, -distance_y))
		else
			return cc.MoveBy:create(time, cc.p(distance_x, -distance_y))
		end
	end

	local is_left = -1
	local random = math.random(1, 2)
	if random == 2 then
		is_left = 1
	end

	local delay_time = param.delay_time or 0
	local fade_time = param.fade_time or 0
	local action_list = {}
	action_list[#action_list + 1] = GenerateActionMoveUp(is_left)
	action_list[#action_list + 1] = GenerateActionMoveDown(is_left)
	action_list[#action_list + 1] = cc.MoveBy:create(0.05, cc.p(5 * is_left * -1, 5))
	action_list[#action_list + 1] = cc.MoveBy:create(0.05, cc.p(5 * is_left * -1, -5))

	if delay_time > 0 then
		action_list[#action_list + 1] = cc.DelayTime:create(delay_time)
	end

	if fade_time > 0 then
		action_list[#action_list + 1] = CCFadeOut:create(fade_time)
	end

	action_list[#action_list + 1] = cc.RemoveSelf:create()
	jumped_text:runAction(cc.Sequence:create(unpack(action_list)))
end

function FlyText:RandomJumpedFade(sprite, custom_font_path, text, param)
	if not param then
		param = {}
	end
	
	local jumped_text = cc.LabelBMFont:create(text, custom_font_path)
	local sprite_rect = sprite:getBoundingBox()
	local percent_x = param.percent_x or 0.5
	local percent_y = param.percent_y or 0.75
	jumped_text:setPosition(sprite_rect.width * percent_x, sprite_rect.height * percent_y)

	local color = param.color or "white"	
	jumped_text:setColor(Def:GetColor(color))
	sprite:addChild(jumped_text)

	local jump_time = param.jump_time or 1
	local delay_time = param.delay_time or 0
	local fade_time = param.fade_time or 0

	local range_min_x = param.range_min_x or 10
	local range_max_x = param.range_max_x or 40
	local range_min_y = param.range_min_y or 60
	local range_max_y = param.range_max_y or 80

	local max_height = param.max_height or 100
	local jump_num = param.jump_num or 1

	local target_x = math.random(range_min_x, range_max_x)
	local target_y = math.random(range_min_y, range_max_y)

	local action_list = {}
	action_list[#action_list + 1] = cc.JumpBy:create(jump_time, cc.p(target_x, target_y), max_height, jump_num)
	action_list[#action_list + 1] = cc.RemoveSelf:create()

	local action_spawn = {
		cc.Sequence:create(unpack(action_list)),
		CCFadeOut:create(jump_time),
	}
	if param.text_scale then
		action_spawn[#action_spawn + 1] = cc.ScaleTo:create(0.1, param.text_scale)
	end
	jumped_text:runAction(cc.Spawn:create(unpack(action_spawn)))
end

function FlyText:VerticalShake(sprite, custom_font_path, text, param)
	if not param then
		param = {}
	end

	local jumped_text = cc.LabelBMFont:create(text, custom_font_path)
	local color = param.color or "white"	
	jumped_text:setColor(Def:GetColor(color))
	sprite:addChild(jumped_text)

	local sprite_rect = sprite:getBoundingBox()
	local percent_x = param.percent_x or 0.5
	local percent_y = param.percent_y or 1
	local text_x = sprite_rect.width * percent_x
	local text_y = sprite_rect.height * percent_y
	jumped_text:setPosition(text_x, text_y)

	local up_time = param.up_time or 0
	local down_time = param.down_time or 0
	local up_y = param.up_y or 0
	local down_y = param.down_y or 0
	local delay_time = param.delay_time or 0
	local fade_time = param.fade_time or 0

	local action_list_text = {}

	if up_time > 0 and up_y ~= 0 then
		action_list_text[#action_list_text + 1] = cc.MoveBy:create(up_time, cc.p(0, up_y))
	end
	
	if down_time > 0 and down_y ~= 0 then
		action_list_text[#action_list_text + 1] = cc.MoveBy:create(down_time, cc.p(0, down_y))
	end
	
	if delay_time > 0 then
		action_list_text[#action_list_text + 1] = cc.DelayTime:create(delay_time)
	end
	
	if fade_time > 0 then
		action_list_text[#action_list_text + 1] = CCFadeOut:create(fade_time)
	end

	action_list_text[#action_list_text + 1] = cc.RemoveSelf:create()

	local action_spawn = {
		cc.Sequence:create(unpack(action_list_text)),
	}
	if param.text_scale then
		action_spawn[#action_spawn + 1] = cc.ScaleTo:create(0.1, param.text_scale)
	end
	jumped_text:runAction(cc.Spawn:create(unpack(action_spawn)))
end

function FlyText:VerticalShakeWithIcon(sprite, custom_font_path, icon_name, text, param)
	if not param then
		param = {}
	end

	local jumped_text = cc.LabelBMFont:create(text, custom_font_path)
	if param.text_scale then
		jumped_text:setScale(param.text_scale)
	end

	local color = param.color or "white"	
	jumped_text:setColor(Def:GetColor(color))
	sprite:addChild(jumped_text)


	local icon = cc.Sprite:createWithSpriteFrameName(icon_name)
	if param.icon_scale then
		icon:setScale(param.icon_scale)
	end
	sprite:addChild(icon)

	local sprite_rect = sprite:getBoundingBox()
	local icon_rect = icon:getBoundingBox()
	local text_rect = jumped_text:getBoundingBox()
	local percent_x = param.percent_x or 0.5
	local percent_y = param.percent_y or 1
	local icon_x = sprite_rect.width * percent_x - (icon_rect.width + text_rect.width) * 0.5 + icon_rect.width / 2
	local text_x = icon_x + icon_rect.width / 2 + text_rect.width / 2
	local icon_y = sprite_rect.height * percent_y
	local text_y = icon_y

	jumped_text:setPosition(text_x, text_y)
	icon:setPosition(icon_x, icon_y)

	local up_time = param.up_time or 0
	local down_time = param.down_time or 0
	local up_y = param.up_y or 0
	local down_y = param.down_y or 0
	local delay_time = param.delay_time or 0
	local fade_time = param.fade_time or 0

	local action_list_icon = {}
	local action_list_text = {}

	if up_time > 0 and up_y ~= 0 then
		action_list_icon[#action_list_icon + 1] = cc.MoveBy:create(up_time, cc.p(0, up_y))
		action_list_text[#action_list_text + 1] = cc.MoveBy:create(up_time, cc.p(0, up_y))
	end
	
	if down_time > 0 and down_y ~= 0 then
		action_list_icon[#action_list_icon + 1] = cc.MoveBy:create(down_time, cc.p(0, down_y))
		action_list_text[#action_list_text + 1] = cc.MoveBy:create(down_time, cc.p(0, down_y))
	end
	
	if delay_time > 0 then
		local action_delay_time = cc.DelayTime:create(delay_time)
		action_list_icon[#action_list_icon + 1] = action_delay_time
		action_list_text[#action_list_text + 1] = action_delay_time
	end
	
	if fade_time > 0 then
		action_list_icon[#action_list_icon + 1] = CCFadeOut:create(fade_time)
		action_list_text[#action_list_text + 1] = CCFadeOut:create(fade_time)
	end
	
	local action_remove_self = cc.RemoveSelf:create()
	action_list_icon[#action_list_icon + 1] = action_remove_self
	action_list_text[#action_list_text + 1] = action_remove_self

	
	jumped_text:runAction(cc.Sequence:create(unpack(action_list_text)))
	icon:runAction(cc.Sequence:create(unpack(action_list_icon)))
end
