--=======================================================================
-- File Name    : scene_base.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-29 21:16:43
-- Description  :
-- Modify       :
--=======================================================================

if not SceneMgr then
	SceneMgr = {}
end

local visible_size = cc.Director:getInstance():getVisibleSize()

if not SceneMgr._SceneBase then
	SceneMgr._SceneBase = Lib:NewClass(LogicNode)
end
local SceneBase = SceneMgr._SceneBase

local MAX_SCALE = 3.0
local SCALE_RATE = 0.005

function SceneBase:Init(scene_name)

	self.scene_name = scene_name
	self.cc_scene_obj = cc.Scene:create()
	if not self.property then
		self.property = {}
	end
	self.layer_list = {}
	self.reg_event_list = {}

	-- 场景默认设为屏幕大小
	self.min_width_scale = 0
	self.min_height_scale = 0

	self.max_scale = MAX_SCALE
	self.scale_rate = 
	
	self:SetWidth(visible_size.width)
	self:SetHeight(visible_size.height)

	Ui:InitScene(scene_name, self.cc_scene_obj)
	self:AddReturnMenu()
	local layer_main = self:CreateLayer("main", Def.ZOOM_LEVEL_WORLD)
	layer_main:setAnchorPoint(cc.p(0, 0))
	self.scale = 1

	local min_width_scale = visible_size.width / self:GetWidth()
	local min_height_scale = visible_size.height / self:GetHeight()

	self.min_scale = min_width_scale > min_height_scale and min_width_scale or min_height_scale

	if self.cocos_ui then
    	Ui:PreloadCocosUI(self:GetName(), self.cocos_ui)
    end

    self:RegisterEventListen()
	self:_Init()

	if self:CanTouch() == 1 then
		self:RegisterTouchEvent()
	end

	if self:IsDebugPhysics() == 1 then
    	local layer_main = self:GetLayer("main")
        local layer_debug_phyiscs = DebugPhysicsLayer:create()

		layer_main:addChild(layer_debug_phyiscs, 10)
    end

	Event:FireEvent("SceneCreate", self:GetClassName(), self:GetName())
end

function SceneBase:Uninit()
	Event:FireEvent("SceneDestroy", self:GetClassName(), self:GetName())

	self:_Uninit()
	self:UnregisterEventListen()

	self.scale = nil
	local layer_main = self:GetLayer("main")
	self.cc_scene_obj:removeChild(layer_main)
	self:RemoveReturnMenu()
	Ui:UninitScene(self.scene_name)
	self.reg_event_list = nil
	self.layer_list = nil
	self.cc_scene_obj = nil
	self.scene_name = nil
end

function SceneBase:CreateLayer(layer_name, z_level)
	if self.layer_list[layer_name] then
		cclog("Layer [%s] create Failed! Already Exists", layer_name)
		return nil
	end
	local layer = cc.Layer:create()
	assert(self:AddLayer(layer_name, layer, z_level) == 1)
	return layer
end

function SceneBase:AddLayer(layer_name, layer, z_level)
	if self.layer_list[layer_name] then
		cclog("Layer [%s] create Failed! Already Exists", layer_name)
		return nil
	end
	if z_level then 
		if z_level > 0 then
			self.cc_scene_obj:addChild(layer, z_level)
		end
	else
		self.cc_scene_obj:addChild(layer)
	end
	self.layer_list[layer_name] = layer
	return 1
end

function SceneBase:GetLayer(layer_name)
	return self.layer_list[layer_name]
end

function SceneBase:GetUI()
	return Ui:GetSceneUi(self:GetName())
end

function SceneBase:GetUILayer()
	local ui_frame = Ui:GetSceneUi(self:GetName())
	return Ui:GetLayer(ui_frame)
end

function SceneBase:GetClassName()
	return self.class_name
end

function SceneBase:GetName()
	return self.scene_name
end

function SceneBase:GetCCObj()
	return self.cc_scene_obj
end

function SceneBase:SetWidth(width)
	self.width = width
	self.min_width_scale = visible_size.width / width

	self.min_scale = self.min_width_scale > self.min_height_scale and self.min_width_scale or self.min_height_scale
end
function SceneBase:SetHeight(height)
	self.height = height
	self.min_height_scale = visible_size.height / height

	self.min_scale = self.min_width_scale > self.min_height_scale and self.min_width_scale or self.min_height_scale
end

function SceneBase:GetWidth()
	return self.width
end

function SceneBase:GetHeight()
	return self.height
end

function SceneBase:MoveCamera(x, y)
	local layer_x, layer_y = visible_size.width / 2 - x, visible_size.height / 2 - y
	return self:MoveMainLayer(layer_x, layer_y)
end

function SceneBase:MoveMainLayer(position_x, position_y)
	local layer_main = self:GetLayer("main")
	assert(layer_main)
	if self:IsLimitDrag() == 1 then
        position_x, position_y = self:GetModifyPosition(position_x, position_y)
    end
    layer_main:setPosition(position_x, position_y)
end

function SceneBase:GetModifyPosition(position_x, position_y)
	local min_x, max_x = visible_size.width - (self:GetWidth() * self.scale), 0
	if min_x > max_x then
		min_x, max_x = max_x, min_x
	end
    local min_y, max_y = visible_size.height - (self:GetHeight() * self.scale),  0
    if min_y > max_y then
    	min_y, max_y = max_y, min_y
    end
    if position_x < min_x then
        position_x = min_x
    elseif position_x > max_x then
        position_x = max_x
    end

    if position_y < min_y then
        position_y = min_y
    elseif position_y > max_y then
        position_y = max_y
    end
    return position_x, position_y
end

function SceneBase:GetScale()
	return self.scale
end

function SceneBase:SetScale(scale, zoom_x, zoom_y, zoom_offset_x, zoom_offset_y)
	local layer_main = self:GetLayer("main")
	if scale < self.min_scale then
		scale = self.min_scale
	elseif self.scale > self.max_scale then
		self.scale = self.max_scale
	end
	if self.scale == scale then
		return
	end

	self.scale = scale
	layer_main:setScale(scale)
	
	if zoom_x and zoom_y then
		self:MoveCamera(zoom_x * self:GetWidth() * scale + zoom_offset_x, zoom_y * self:GetHeight() * scale + zoom_offset_y)
	end
end

function SceneBase:SetMaxScale(max_scale)
	self.max_scale = max_scale
end

function SceneBase:SetScaleRate(scale_rate)
	self.scale_rate = scale_rate
end

function SceneBase:AddReturnMenu()
    local element_list = nil
    if scene_name ~= "MainScene" then
	    element_list = {
		    [1] = {
		        [1] = {
					item_name = "返回主菜单",
		        	callback_function = function()
		        		SceneMgr:UnLoadCurrentScene()
		        	end,
		        },
		        [2] = {
					item_name = "重载脚本和场景",
		        	callback_function = function()
	        			self:Reload()
	        			SceneMgr:UnLoadCurrentScene()
						local scene = SceneMgr:LoadScene(current_scene_name)
						scene:SysMsg("重载完毕", "green")
		        	end,
		        },
		    },
		}
	elseif device == "win32" then
		element_list = {
		    [1] = {
		        [1] = {
					item_name = "重载脚本",
		        	callback_function = function()
	        			self:Reload()
		        	end,
		        },
		    },
		}
	end
	if element_list then
	    local menu_array = Menu:GenerateByString(element_list, 
	    	{font_name = Def.menu_font_name, font_size = 30, align_type = "right", interval_x = 20}
	    )
	    local ui_frame = self:GetUI()
	    local menu_tools = cc.Menu:create(unpack(menu_array))
	    Ui:AddElement(ui_frame, "Menu", "ReturnMenu", visible_size.width, visible_size.height, menu_tools)
	end
end

function SceneBase:RemoveReturnMenu()
	local ui_frame = self:GetUI()
	Ui:RemoveElement(ui_frame, "Menu", "ReturnMenu")
end

function SceneBase:IsDebugPhysics()
	if self.property and self.property.debug_physics == 1 then
		return 1
	end
end

function SceneBase:SetTouchEnable(can_touch)
	self.property.can_touch = can_touch
end

function SceneBase:CanTouch()
	if self.property and self.property.can_touch == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanPick()
	if self.property and self.property.can_pick == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanDrag()
	if self.property and self.property.can_drag == 1 then
		return 1
	end
	return 0
end

function SceneBase:IsLimitDrag()
	if self.property and self.property.limit_drag == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanScale()
	if self.property and self.property.can_scale == 1 then
		return 1
	end
	return 0
end

function SceneBase:IsMove()
	return self.is_move
end

function SceneBase:RegisterTouchEvent()
	local layer_main = self:GetLayer("main")

	local touch_begin_points = {}
    local touch_start_points = {}
    local touch_distance = nil
    local zoom_x, zoom_y = nil, nil
    local zoom_offset_x, zoom_offset_y = nil, nil
    local current_touches = 0
    local function onTouchBegan(touches)
    	-- print("began", #touches, touches[3], touches[6])
    	for i = 1, #touches, 3 do
    		if not touch_begin_points[touches[i + 2]] then
	    		touch_begin_points[touches[i + 2]] = {x = touches[i], y = touches[i + 1]}
	    		touch_start_points[touches[i + 2]] = {x = touches[i], y = touches[i + 1]}
	    		current_touches = current_touches + 1
	    	end
    	end
        local layer_x, layer_y = layer_main:getPosition()
        if current_touches == 1 then
        	if self.OnTouchBegan then
        		local x, y = touches[1], touches[2]
        		local scale = self:GetScale()
        		self:OnTouchBegan((x - layer_x) / scale, (y - layer_y) / scale)
        	end
        	self.is_move = nil
        elseif current_touches == 2 and self:CanScale() == 1 then
        	local x1, y1, x2, y2
        	for id, touch_info in pairs(touch_begin_points) do  		
        		if not x1 or not y1 then
        			x1, y1 = touch_info.x, touch_info.y
        		elseif not x2 or not y2 then
        			x2, y2 = touch_info.x, touch_info.y
        		else
        			break
        		end
        	end
        	touch_distance = Lib:GetDistance(x1, y1, x2, y2)
	       	zoom_x , zoom_y = ((x1 + x2) / 2 - layer_x) / (self:GetWidth() * self.scale), ((y1 + y2) / 2 - layer_y) / (self:GetHeight() * self.scale)
	       	zoom_offset_x, zoom_offset_y = visible_size.width / 2 - (x1 + x2) / 2 , visible_size.height / 2 - (y1 + y2) / 2
        end
        return true
    end

    local function onTouchMoved(touches)
    	if current_touches == 1 then
    		local x, y = touches[1], touches[2]
    		local touch_begin_point = touch_begin_points[touches[3]]
            local layer_x, layer_y = layer_main:getPosition()
            local bool_pick = 0
            self.is_move = 1
        	if self.OnTouchMoved then
        		local scale = self:GetScale()
        		
        		if self:OnTouchMoved((x - layer_x) / scale, (y - layer_y) / scale) == 1 then
        			bool_pick = 1
        		end
            end
            if bool_pick ~= 1 and self:CanDrag() == 1 then
                local new_layer_x, new_layer_y = layer_x + x - touch_begin_point.x, layer_y + y - touch_begin_point.y
                self:MoveMainLayer(new_layer_x, new_layer_y)
            end
            touch_begin_point.x = x
            touch_begin_point.y = y
        elseif current_touches == 2 and self:CanScale() == 1 then
        	for i = 1, #touches, 3 do
	    		touch_begin_points[touches[i + 2]] = {x = touches[i], y = touches[i + 1]}
	    	end
	    	local x1, y1, x2, y2
        	for id, touch_info in pairs(touch_begin_points) do  		
        		if not x1 or not y1 then
        			x1, y1 = touch_info.x, touch_info.y
        		elseif not x2 or not y2 then
        			x2, y2 = touch_info.x, touch_info.y
        		else
        			break
        		end
        	end
        	local distance = Lib:GetDistance(x1, y1, x2, y2) * self.scale
        	if touch_distance then
	        	local change_scale = self.scale + (distance - touch_distance) * self.scale_rate
	        	self:SetScale(change_scale, zoom_x, zoom_y, zoom_offset_x, zoom_offset_y)
	        end
	        touch_distance = distance
        end
    end

    local function onTouchEnded(touches)
    	-- print("end", #touches, touches[3], touches[6])
        local layer_x, layer_y = layer_main:getPosition()
    	if current_touches == 1 then
	        if self.OnTouchEnded then
	        	local x, y = touches[1], touches[2]
	        	local scale = self:GetScale()
	    		self:OnTouchEnded((x - layer_x) / scale, (y - layer_y) / scale)
	    	end
	    	self.is_move = nil
	    elseif current_touches == 2 then
	        touch_distance = nil
	        zoom_x, zoom_y = nil
	        zoom_offset_x, zoom_offset_y = nil, nil
        end
        for i = 1, #touches, 3 do
        	if touch_begin_points[touches[i + 2]] then
	    		touch_begin_points[touches[i + 2]] = nil
	    		touch_start_points[touches[i + 2]] = nil
	    		current_touches = current_touches - 1
	    	end
    	end
    	
    end

    local function onTouch(eventType, touches)
        if eventType == "began" then   
            return onTouchBegan(touches)
        elseif eventType == "moved" then
            return onTouchMoved(touches)
        else
            return onTouchEnded(touches)
        end
    end

    layer_main:registerScriptTouchHandler(onTouch, true)
    layer_main:setTouchEnabled(true)
end

function SceneBase:Reload()
	if device == "win32" then
		ReloadScript()
		self:SysMsg("脚本重载完毕", "green")
	end
end

function SceneBase:SysMsg(msg, color_name)
	local ui_frame = self:GetUI()
	if ui_frame then
		Ui:SysMsg(ui_frame, msg, color_name)
	end
end

function SceneBase:SetSysMsgSize(font_size)
	local ui_frame = self:GetUI()
	if ui_frame then
		Ui:SetSysMsgSize(ui_frame, font_size)
	end
end

function SceneBase:SetSysMsgFont(font_name)
	local ui_frame = self:GetUI()
	if ui_frame then
		Ui:SetSysMsgFont(ui_frame, font_name)
	end
end

function SceneBase:LoadCocosUI(json_path)
	local layer = Ui:GetLayer(self:GetUI())
	return Ui:LoadJson(layer, json_path)
end