--=======================================================================
-- File Name    : menu.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not MenuMgr then
	MenuMgr = {}
end

function MenuMgr:Init()
	self.menu_list = {}
	return 1
end

function MenuMgr:Uninit()
	self.menu_list = {}
end

function MenuMgr:CreateMenu(menu_name, background_image_path)
	if self.menu_list[menu_name] then
		cclog("CreateMenu[%s] Failed Already Exists", menu_name)
		return self.menu_list[menu_name].layer
	end

	local layer_menu = CCLayer:create()
	local background_size = nil
	if background_image_path then
		local background_sprite = CCSprite:create(background_image_path)
		if background_sprite then
			layer_menu:addChild(background_sprite, 1, 100)
			background_sprite:setPosition(0, 0)
			background_sprite:setAnchorPoint({0.5, 0.5})
			background_size = background_sprite:getTextureRect().size
		end
	end

	self.menu_list[menu_name] = {layer = layer_menu, background_size = background_size}

    return layer_menu
end

function MenuMgr:DestroyMenu(menu_name)
	self.menu_list[menu_name] = nil
end

function MenuMgr:UpdateByImage(menu_name, element_list, params)
	local menu_list = self:GetMenu(menu_name)
	if not menu_list then
		cclog("CreateMenu[%s] is not Exists", menu_name)
		return 0
	end

	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0
	
	local menu_array = {}
	local layer_menu = menu_list.layer
	if layer_menu:getChildByTag(1) then
		layer_menu:removeChildByTag(1, true)
	end

	
	local item_height = nil
	local y = 0
	local max_width = 0
	local width_sum = 0
	for row, row_elements in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(row_elements) do
			local menu = cc.MenuItemImage:create(
				element.normal_image,
				element.selected_image,
				element.disabled_image
			)
			menu:registerScriptTapHandler(element.callback_function)
			local item_width = menu:getContentSize().width
			if not item_height then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array+ 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	local menu_tools = cc.Menu:create(unpack(menu_array))
    if align_type == "center" and item_height then
		local nOffsetY = math.floor(-y / 2)
		menu_tools:setPosition(0, nOffsetY)
	else
    	menu_tools:setPosition(0, 0)
    end
    local background_sprite = layer_menu:getChildByTag(100)
    if background_sprite then
    	local background_size = menu_list.background_size
    	background_sprite:setScaleX((max_width + 20) / background_size.width)
    	background_sprite:setScaleY((10 - y) / background_size.height)
    end
    layer_menu:addChild(menu_tools, 1, 1)
    return 1
end

function MenuMgr:UpdateBySprite(menu_name, element_list, params)
	local menu_list = self:GetMenu(menu_name)
	if not menu_list then
		cclog("CreateMenu[%s] is not Exists", menu_name)
		return 0
	end

	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0
	
	local menu_array = {}
	local layer_menu = menu_list.layer
	if layer_menu:getChildByTag(1) then
		layer_menu:removeChildByTag(1, true)
	end

	local item_height = nil
	local y = 0
	local max_width = 0
	local width_sum = 0
	for row, tbRow in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(tbRow) do
			local menu = CCMenuItemSprite:create(element.sprite_normal, element.sprite_selected)
			local normal_rect = element.sprite_normal:getBoundingBox()
			local select_rect = element.sprite_selected:getBoundingBox()
			local offset_x = (normal_rect.width - select_rect.width) / 2
			local offset_y = (normal_rect.height - select_rect.height) / 2
           element.sprite_selected:setPosition(offset_x, offset_y)
			menu:registerScriptTapHandler(element.callback_function)

			local item_width = menu:getContentSize().width
			if not item_height then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array+ 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	local menu_tools = cc.Menu:create(unpack(menu_array))
    if align_type == "center" and item_height then
		local nOffsetY = math.floor(-y / 2)
		menu_tools:setPosition(0, nOffsetY)
	else
    	menu_tools:setPosition(0, 0)
    end
    local background_sprite = layer_menu:getChildByTag(100)
    if background_sprite then
    	local background_size = menu_list.background_size
    	background_sprite:setScaleX((max_width + 20) / background_size.width)
    	background_sprite:setScaleY((10 - y) / background_size.height)
    end
    layer_menu:addChild(menu_tools, 1, 1)
    return 1
end

function MenuMgr:UpdateByString(menu_name, element_list, params)
	local font_name = params.font_name or ""
	local font_size = params.font_size or 16
	local align_type = params.align_type or "left"
	local interval_x = params.interval_x or 15
	local interval_y = params.interval_y or 0

	local menu_list = self:GetMenu(menu_name)
	if not menu_list then
		cclog("CreateMenu[%s] is not Exists", menu_name)
		return 0
	end
	local menu_array = {}
	local layer_menu = menu_list.layer
	if layer_menu:getChildByTag(1) then
		layer_menu:removeChildByTag(1, true)
	end

	local item_height = nil
	local y = 0
	local max_width = 0
	local width_sum = 0
	for row, row_elements in ipairs(element_list) do
		width_sum = 0
		local x = 0
		if row ~= 1 then
			y = y - interval_y
		end
		local row_menu_list = {}
		for column, element in ipairs(row_elements) do
			local ccLabel = CCLabelTTF:create(element.item_name or "错误的菜单项", font_name, font_size)
			local menu = CCMenuItemLabel:create(ccLabel)
			menu:registerScriptTapHandler(element.callback_function)
			local item_width = menu:getContentSize().width
			if not item_height then
		    	item_height = menu:getContentSize().height
		    end

			if align_type == "right" then
				if column ~= 1 then
					x = x - interval_x
					width_sum = width_sum + interval_x
				end
		    	x = x - item_width / 2
		    	width_sum = width_sum + item_width
		    	menu:setPosition(x, y - item_height / 2)
		    	x = x - item_width / 2
		    else
		    	if column ~= 1 then
		    		x = x + interval_x
		    		width_sum = width_sum + interval_x
		    	end
		    	x = x + item_width / 2
		    	menu:setPosition(x, y - item_height / 2)
				x = x + item_width / 2
				width_sum = width_sum + item_width
		    end
		    row_menu_list[#row_menu_list + 1] = menu
	    	menu_array[#menu_array + 1] = menu
	    end
	    if align_type == "center" then
	    	local offset_x = math.floor(x / 2)
	    	for _, menu in ipairs(row_menu_list) do
	    		local menu_x, menu_y = menu:getPosition()
	    		menu:setPosition(menu_x - offset_x, menu_y)
	    	end
		end
		y = y - item_height
		if width_sum > max_width then
			max_width = width_sum
		end
	end
	local menu_tools = cc.Menu:create(unpack(menu_array))
	if align_type == "center" and item_height then
		local nOffsetY = math.floor(-y / 2)
		menu_tools:setPosition(0, nOffsetY)
	else
    	menu_tools:setPosition(0, 0)
    end
    local background_sprite = layer_menu:getChildByTag(100)
    if background_sprite then
    	local background_size = menu_list.background_size
    	background_sprite:setScaleX((max_width + 20) / background_size.width)
    	background_sprite:setScaleY((10 - y) / background_size.height)
    end
    layer_menu:addChild(menu_tools, 1, 1)

    return 1
end

function MenuMgr:SetVisible(menu_name, is_visible)
	local menu_list = self:GetMenu(menu_name)
	local layer_menu = menu_list.layer
	layer_menu:setVisible(is_visible)
end

function MenuMgr:IsVisible(menu_name)
	local menu_list = self:GetMenu(menu_name)
	local layer_menu = menu_list.layer
	return layer_menu:isVisible()
end

function MenuMgr:GetMenu(menu_name)
	return self.menu_list[menu_name]
end
