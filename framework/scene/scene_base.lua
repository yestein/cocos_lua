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
if not SceneMgr._SceneBase then
	SceneMgr._SceneBase = {}
end

local SceneBase = SceneMgr._SceneBase
local tb_visible_size = CCDirector:getInstance():getVisibleSize()

function SceneBase:DeclareListenEvent(str_event, str_func)
	self.tb_event_listen[str_event] = str_func
end

function SceneBase:Init(str_scene_name)

	self.str_scene_name = str_scene_name
	self.cc_scene = cc.Scene:create()
	self.tb_cc_layer = {}
	self.tb_reg_event = {}

	-- 场景默认设为屏幕大小
	self.min_width_scale = 0
	self.min_height_scale = 0
	
	self:SetWidth(tb_visible_size.width)
	self:SetHeight(tb_visible_size.height)

	self:RegisterEventListen()
	Ui:InitScene(str_scene_name, self.cc_scene)
	self:AddReturnMenu()
	local layer_main = self:CreateLayer("main", Def.ZOOM_LEVEL_WORLD)
	layer_main:setAnchorPoint(cc.p(0, 0))
	self.scale = 1

	local min_width_scale = tb_visible_size.width / self:GetWidth()
	local min_height_scale = tb_visible_size.height / self:GetHeight()

	self.min_scale = min_width_scale > min_height_scale and min_width_scale or min_height_scale

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
	self.scale = nil
	local cc_layer_main = self:GetLayer("main")
	self.cc_scene:removeChild(cc_layer_main)
	self:RemoveReturnMenu()
	Ui:UninitScene(self.str_scene_name)
	self:UnregisterEventListen()
	self.tb_reg_event = nil
	self.tb_cc_layer = nil
	self.cc_scene = nil
	self.str_scene_name = nil
end

function SceneBase:SetWidth(width)
	self.width = width
	self.min_width_scale = tb_visible_size.width / width

	self.min_scale = self.min_width_scale > self.min_height_scale and self.min_width_scale or self.min_height_scale
end
function SceneBase:SetHeight(height)
	self.height = height
	self.min_height_scale = tb_visible_size.width / height

	self.min_scale = self.min_width_scale > self.min_height_scale and self.min_width_scale or self.min_height_scale
end

function SceneBase:GetWidth()
	return self.width
end

function SceneBase:GetHeight()
	return self.height
end

function SceneBase:CreateLayer(str_layer_name, z_level)
	if self.tb_cc_layer[str_layer_name] then
		cclog("Layer [%s] create Failed! Already Exists", str_layer_name)
		return nil
	end
	local cc_layer = cc.Layer:create()
	assert(self:AddLayer(str_layer_name, cc_layer, z_level) == 1)
	return cc_layer
end

function SceneBase:AddLayer(str_layer_name, cc_layer, z_level)
	if self.tb_cc_layer[str_layer_name] then
		cclog("Layer [%s] create Failed! Already Exists", str_layer_name)
		return nil
	end
	if z_level then 
		if z_level > 0 then
			self.cc_scene:addChild(cc_layer, z_level)
		end
	else
		self.cc_scene:addChild(cc_layer)
	end
	self.tb_cc_layer[str_layer_name] = cc_layer
	return 1
end

function SceneBase:GetLayer(str_layer_name)
	return self.tb_cc_layer[str_layer_name]
end

function SceneBase:RegisterEventListen()
	for str_event, str_func in pairs(self.tb_event_listen) do
		if not self.tb_reg_event[str_event] then
			local id_reg = Event:RegistEvent(str_event, self[str_func], self)
			self.tb_reg_event[str_event] = id_reg
		else
			assert(false)
		end
	end
end

function SceneBase:UnregisterEventListen()
	for str_event, id_reg in pairs(self.tb_reg_event) do
		Event:UnRegistEvent(str_event, id_reg)
	end
	self.tb_reg_event = {}
end

function SceneBase:GetUI()
	return Ui:GetSceneUi(self:GetName())
end

function SceneBase:GetClassName()
	return self.str_class_name
end

function SceneBase:GetName()
	return self.str_scene_name
end

function SceneBase:GetCCObj()
	return self.cc_scene
end

function SceneBase:SysMsg(szMsg, str_color)
	local tb_ui = self:GetUI()
	if tb_ui then
		Ui:SysMsg(tb_ui, szMsg, str_color)
	end
end

function SceneBase:AddReturnMenu()
	local str_name = self:GetName()
	local tbVisibleSize = CCDirector:getInstance():getVisibleSize()
	local layerMenu = MenuMgr:CreateMenu(str_name)
    layerMenu:setPosition(tbVisibleSize.width, tbVisibleSize.height)
    self.cc_scene:addChild(layerMenu, Def.ZOOM_LEVEL_MENU)
    local tbElement = nil
    if str_name ~= "MainScene" then
	    tbElement = {
		    [1] = {
		        [1] = {
					szItemName = "返回主菜单",
		        	fnCallBack = function()
		        		SceneMgr:DestroyScene(str_name)
		        		local cc_scene = SceneMgr:GetSceneObj("MainScene")
		        		CCDirector:getInstance():replaceScene(cc_scene)
		        	end,
		        },
		        [2] = {
					szItemName = "重载脚本和场景",
		        	fnCallBack = function()
		        		if device == "win32" then
		        			self:Reload()
		        		end
		        		SceneMgr:DestroyScene(str_name)
		        		local cc_scene = SceneMgr:GetSceneObj("MainScene")
		        		CCDirector:getInstance():replaceScene(cc_scene)
						local tbScene = GameMgr:LoadScene(str_name)
						tbScene:SysMsg("重载完毕", "green")
		        	end,
		        },
		    },
		}
	else
		tbElement = {
		    [1] = {
		        [1] = {
					szItemName = "重载脚本",
		        	fnCallBack = function()
		        		if device == "win32" then
		        			self:Reload()
		        		end
		        	end,
		        },
		    },
		}
	end
    MenuMgr:UpdateByString(str_name, tbElement, 
    	{szFontName = Def.szMenuFontName, nSize = 30, szAlignType = "right", nIntervalX = 20}
    )
end

function SceneBase:RemoveReturnMenu()
	local str_name = self:GetName()
	MenuMgr:DestroyMenu(str_name)
end

function SceneBase:IsDebugPhysics()
	if self.tb_property and self.tb_property.debug_physics == 1 then
		return 1
	end
end

function SceneBase:CanTouch()
	if self.tb_property and self.tb_property.can_touch == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanPick()
	if self.tb_property and self.tb_property.can_pick == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanDrag()
	if self.tb_property and self.tb_property.can_drag == 1 then
		return 1
	end
	return 0
end

function SceneBase:IsLimitDrag()
	if self.tb_property and self.tb_property.limit_drag == 1 then
		return 1
	end
	return 0
end

function SceneBase:CanScale()
	if self.tb_property and self.tb_property.can_scale == 1 then
		return 1
	end
	return 0
end

function SceneBase:RegisterTouchEvent()
	local cc_layer_main = self:GetLayer("main")

	local touch_begin_points = {}
    local touch_start_points = {}
    local touch_distance = nil
    local zoom_x, zoom_y = nil, nil
    local zoom_offset_x, zoom_offset_y = nil, nil
    local current_touches = 0
    local function onTouchBegan(touches)
    	-- print("began", #touches, touches[3], touches[6])
    	for i = 1, #touches, 3 do
    		touch_begin_points[touches[i + 2]] = {x = touches[i], y = touches[i + 1]}
    		touch_start_points[touches[i + 2]] = {x = touches[i], y = touches[i + 1]}
    		current_touches = current_touches + 1
    	end
        local layer_x, layer_y = cc_layer_main:getPosition()            
        if current_touches == 1 and self:CanPick() == 1 then
        	if self.OnTouchBegan then
        		local x, y = touches[1], touches[2]
        		self:OnTouchBegan(x - layer_x, y - layer_y)
        	end
        	-- PhysicsWorld:MouseDown(x - nX,  y - nY)
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
	       	zoom_offset_x, zoom_offset_y = tb_visible_size.width / 2 - (x1 + x2) / 2 , tb_visible_size.height / 2 - (y1 + y2) / 2
        end
        return true
    end

    local function onTouchMoved(touches)
    	if current_touches == 1 and self:CanDrag() == 1 then
    		local x, y = touches[1], touches[2]
    		local touch_begin_point = touch_begin_points[touches[3]]
            local layer_x, layer_y = cc_layer_main:getPosition()
            local bool_pick = 0
        	if self.OnTouchMoved then
        		if self:OnTouchMoved(x - layer_x, y - layer_y) == 1 then
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
        	local distance = Lib:GetDistance(x1, y1, x2, y2)
        	if touch_distance then
	        	local change_scale = self.scale + (distance - touch_distance) * Def.SCALE_RATE
	        	self:SetScale(change_scale, zoom_x, zoom_y, zoom_offset_x, zoom_offset_y)
	        end
	        touch_distance = distance
        end
    end

    local function onTouchEnded(touches)
    	-- print("end", #touches, touches[3], touches[6])
        local nX, nY = cc_layer_main:getPosition()
    	if current_touches == 1 then
	        if self.OnTouchEnded then
	        	local x, y = touches[1], touches[2]
	    		self:OnTouchEnded(x - nX, y - nY)
	    	end
	    elseif current_touches == 2 then
	        touch_distance = nil
	        zoom_x, zoom_y = nil
	        zoom_offset_x, zoom_offset_y = nil, nil
        end
        for i = 1, #touches, 3 do
    		touch_begin_points[touches[i + 2]] = nil
    		touch_start_points[touches[i + 2]] = nil
    		current_touches = current_touches - 1
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

    cc_layer_main:registerScriptTouchHandler(onTouch, true)
    cc_layer_main:setTouchEnabled(true)
end

function SceneBase:MoveCamera(x, y)
	local layer_x, layer_y = tb_visible_size.width / 2 - x, tb_visible_size.height / 2 - y
	return self:MoveMainLayer(layer_x, layer_y)
end

function SceneBase:MoveMainLayer(position_x, position_y)
	local cc_layer_main = self:GetLayer("main")
	assert(cc_layer_main)
	if self:IsLimitDrag() == 1 then
        position_x, position_y = self:GetModifyPosition(position_x, position_y)
    end
    cc_layer_main:setPosition(position_x, position_y)
end

function SceneBase:GetModifyPosition(position_x, position_y)
	local min_x, max_x = tb_visible_size.width - (self:GetWidth() * self.scale), 0
	if min_x > max_x then
		min_x, max_x = max_x, min_x
	end
    local min_y, max_y = tb_visible_size.height - (self:GetHeight() * self.scale),  0
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

function SceneBase:SetScale(scale, zoom_x, zoom_y, zoom_offset_x, zoom_offset_y)
	local cc_layer_main = self:GetLayer("main")
	if scale < self.min_scale then
		scale = self.min_scale
	elseif self.scale > Def.MAX_SCALE then
		self.scale = Def.MAX_SCALE
	end
	if self.scale == scale then
		return
	end

	self.scale = scale
	cc_layer_main:setScale(scale)
	
	if zoom_x and zoom_y then
		self:MoveCamera(zoom_x * self:GetWidth() * scale + zoom_offset_x, zoom_y * self:GetHeight() * scale + zoom_offset_y)
	end
end

function SceneBase:Reload()
	function reload(str_file)
		dofile(str_file)
		print("Reload\t["..str_file.."]")
	end
	print("开始重载脚本...")
	reload("script/scene/scene_base.lua")
	reload("script/scene/scene_mgr.lua")
	reload("script/scene/demo_scene.lua")
	reload("script/scene/construct_scene.lua")
	reload("script/physics/physics_lib.lua")
	reload("script/physics/physics_mgr.lua")

	reload("script/battle/battle_logic.lua")
	
	reload("script/game_mgr.lua")
	reload("script/lib.lua")
	reload("script/menu.lua")
	reload("script/misc_math.lua")
	reload("script/ui.lua")
	reload("script/define.lua")

	
	print("脚本重载完毕")
end