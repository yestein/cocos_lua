--=======================================================================
-- File Name    : label_effect.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/4/9 17:36:22
-- Description  : description
-- Modify       : 
--=======================================================================

if not LabelEffect then
	LabelEffect = {}
end

function LabelEffect:EnableOutline(label, font_color, outline_color, outline_width)
	if __platform == cc.PLATFORM_OS_IPHONE or __platform == cc.PLATFORM_OS_IPAD or __platform == cc.PLATFORM_OS_ANDROID then
		if outline_color and outline_width then
			label:enableOutline(outline_color, outline_width)
		end
	end
	if font_color then
		if __platform == cc.PLATFORM_OS_IPHONE or __platform == cc.PLATFORM_OS_IPAD or __platform == cc.PLATFORM_OS_ANDROID then
			label:setTextColor(font_color)
		else
			label:setColor(font_color)
		end
	end
end

function LabelEffect:EnableShadow(label, shadow_color, shadow_size)
	if shadow_color and shadow_size then
		ccLabel:enableShadow(shadow_color, shadow_size)
	end
end