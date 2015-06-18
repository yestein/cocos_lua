--=======================================================================
-- File Name    : ui.lua
-- Creator      : yulei(yulei1@kingsoft.com)
-- Date         : 2014-01-09 17:56:00
-- Description  :
-- Modify       :
--=======================================================================

if not Ui then
    Ui = {}
end

Ui.MSG_MAX_COUNT = 5

--keep same with "cocos\gui\UIWidget.h"
Ui.TOUCH_EVENT_BEGAN    = 0
Ui.TOUCH_EVENT_MOVED    = 1
Ui.TOUCH_EVENT_ENDED    = 2
Ui.TOUCH_EVENT_CANCELED = 3

local title_font_name = "MarkerFelt-Thin"
if __platform == cc.PLATFORM_OS_WINDOWS then
    title_font_name = "Microsoft Yahei"
end

function Ui:Uninit()
    self.scene_ui_list = {}
    return 1
end

function Ui:Init()
    self.scene_ui_list = {}
    return 1
end

function Ui:InitScene(scene, cc_scene)
    local scene_name = scene:GetName()
    if self.scene_ui_list[scene_name] then
        cclog("[%s]Already Exists", scene_name)
        return
    end
    
    local ui_frame = {}
	ui_frame.element_list = {
        ["MENU"] = {},
        ["LABELTTF"] = {},
        ["LABELBMFONT"] = {},
        ["LABEL"] = {},
        ["DRAW"] = {},
    }

    ui_frame.sysmsg_list = {}    

	local cc_layer_ui = CCLayer:create()        

    for i = 1, Ui.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = CCLabelTTF:create("系统提示", title_font_name, 40)
        cc_layer_ui:addChild(cc_labelttf_sysmsg)
        cc_labelttf_sysmsg:setLocalZOrder(Def.ZOOM_LEVEL_SYSMSG)
        local tbMsgRect = cc_labelttf_sysmsg:getBoundingBox()
        cc_labelttf_sysmsg:setPosition(visible_size.width / 2, visible_size.height / 2 - (2 - i) * tbMsgRect.height)
        cc_labelttf_sysmsg:setOpacity(0)
        ui_frame.sysmsg_list[i] = cc_labelttf_sysmsg
    end
    ui_frame.index_sysmsg = 1

    cc_scene:addChild(cc_layer_ui, Def.ZOOM_LEVEL_TITLE)

    ui_frame.cc_scene = cc_scene
    ui_frame.cc_layer_ui = cc_layer_ui

    local border_height = Movie:GetBorderHeight()
    local movie_boder_up = cc.DrawNode:create()
    local fillColor = cc.c4b(0, 0, 0, 1)
    local borderColor = cc.c4b(255, 0, 255, 125)
    local polygon = {cc.p(0, 0), cc.p(visible_size.width, 0), cc.p(visible_size.width, border_height), cc.p(0, border_height)}
    movie_boder_up:drawPolygon(polygon, 4, fillColor, 0, borderColor)
    Ui:AddElement(ui_frame, "DRAW", "MovieBorderUp", 0, visible_size.height, movie_boder_up)

    local movie_boder_down = cc.DrawNode:create()
    local fillColor = cc.c4b(0, 0, 0, 1)
    local borderColor = cc.c4b(255, 0, 255, 125)
    local polygon = {cc.p(0, 0), cc.p(visible_size.width, 0), cc.p(visible_size.width, border_height), cc.p(0, border_height)}
    movie_boder_down:drawPolygon(polygon, 4, fillColor, 0, borderColor)
    Ui:AddElement(ui_frame, "DRAW", "MovieBorderDown", 0, -border_height, movie_boder_down)

    self.scene_ui_list[scene_name] = ui_frame

    self:PreloadCocosUI(scene_name, scene.cocos_ui)
end

function Ui:UninitScene(scene_name)
    local ui_frame = self.scene_ui_list[scene_name]
    if not ui_frame then
        cclog("[%s] Not Exitst", scene_name)
        return
    end
    for _, tb_type in pairs(ui_frame.element_list) do
        for _, cc_node in pairs(tb_type) do
            ui_frame.cc_layer_ui:removeChild(cc_node, true)
        end
    end
    for _, cc_lable in pairs(ui_frame.sysmsg_list) do
        ui_frame.cc_layer_ui:removeChild(cc_lable, true)
    end
    ui_frame.cc_scene:removeChild(ui_frame.cc_layer_ui)

    ui_frame.element_list = nil
    ui_frame.sysmsg_list = nil
    ui_frame.cc_scene = nil
    ui_frame.cc_layer_ui = nil
    self.scene_ui_list[scene_name] = nil
end

function Ui:GetSceneUi(scene_name)
    local tb_ret = self.scene_ui_list[scene_name]
    if not tb_ret then
        cclog("[%s] UI Not Exists", scene_name)
    end
    return tb_ret
end

function Ui:GetLayer(ui_frame)
    return ui_frame.cc_layer_ui
end

function Ui:GetTypeElement(ui_frame, element_type)
    if not ui_frame.element_list[element_type] then
        ui_frame.element_list[element_type] = {}
    end
    tb_ret = ui_frame.element_list[element_type]
    return tb_ret
end

function Ui:AddElement(ui_frame, element_type, element_name, position_x, position_y, element)
    local element_list = self:GetTypeElement(ui_frame, element_type)
    if not element_list then
        return
    end
    if element_list[element_name] then
        assert(false, "[%s][%s]Already Exists", element_type, element_name)
        return
    end
    ui_frame.cc_layer_ui:addChild(element)
    if position_x and position_y then
        element:setPosition(position_x, position_y)
    end
    element_list[element_name] = element
end

function Ui:GetElement(ui_frame, element_type, element_name)
    local element_list = self:GetTypeElement(ui_frame, element_type)
    if not element_list then
        return
    end
    if not element_list[element_name] then
        return
    end
    return element_list[element_name]
end

function Ui:RemoveElement(ui_frame, element_type, element_name)
    local element_list = self:GetTypeElement(ui_frame, element_type)
    if not element_list then
        return 0
    end
    if not element_list[element_name] then
        cclog("[%s][%s] not Exists", element_type, element_name)
        return 0
    end
    ui_frame.cc_layer_ui:removeChild(element_list[element_name], true)
    element_list[element_name] = nil
end

function Ui:SetVisible(ui_frame, element_type, element_name, is_visible)
    local element = self:GetElement(ui_frame, element_type, element_name)
    element:setVisible(is_visible)
end

function Ui:SetSysMsgSize(ui_frame, font_size)
    for i = 1, self.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = ui_frame.sysmsg_list[i]
        cc_labelttf_sysmsg:setFontSize(font_size)
    end
end

function Ui:SetSysMsgFont(ui_frame, font_name)
    for i = 1, self.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = ui_frame.sysmsg_list[i]
        cc_labelttf_sysmsg:setFontName(font_name)
    end
end

function Ui:SysMsg(ui_frame, text_content, color_name)
    if not color_name then
        color_name = "white"
    end
    for i = 1, self.MSG_MAX_COUNT do
        local num_index = ui_frame.index_sysmsg - i + 1
        if num_index <= 0 then
            num_index = num_index + self.MSG_MAX_COUNT
        end
        local cc_labelttf_sysmsg = ui_frame.sysmsg_list[num_index]
        if i == 1 then
            local color = Def.color_list[color_name]
            cc_labelttf_sysmsg:setOpacity(255)
            cc_labelttf_sysmsg:setString(text_content)
            cc_labelttf_sysmsg:setColor(color)
            cc_labelttf_sysmsg:stopAllActions()
            cc_labelttf_sysmsg:runAction(CCFadeOut:create(3))
        end        
        local tbMsgRect = cc_labelttf_sysmsg:getBoundingBox()        
        cc_labelttf_sysmsg:setPosition(visible_size.width / 2, visible_size.height - (self.MSG_MAX_COUNT - i + 1) * tbMsgRect.height)
    end
    ui_frame.index_sysmsg = ui_frame.index_sysmsg + 1
    if ui_frame.index_sysmsg > self.MSG_MAX_COUNT then
        ui_frame.index_sysmsg = ui_frame.index_sysmsg - self.MSG_MAX_COUNT
    end
end

function Ui:LoadJson(cc_layer, json_file_path)
    local root_widget = ccs.GUIReader:getInstance():widgetFromJsonFile(json_file_path)
    local widget_rect = root_widget:getSize()
    cc_layer:addChild(root_widget)
    return root_widget, widget_rect
end

function Ui:PreloadCocosUI(scene_name, ui_list)
    local ui_frame = self:GetSceneUi(scene_name)
    if ui_list and ui_frame then
        if not ui_frame.cocos_widget then
            ui_frame.cocos_widget = {}
        end
        local scene = SceneMgr:GetScene(scene_name)
        for json_file_path, data in pairs(ui_list) do
            local ui_name = data.name
            local root_widget = ccs.GUIReader:getInstance():widgetFromJsonFile(json_file_path)
            scene:AddLayer(ui_name, root_widget)
            local widget_rect = root_widget:getSize()
            root_widget:setScaleX(visible_size.width / widget_rect.width)
            root_widget:setScaleY(visible_size.height / widget_rect.height)
            if data.hide == 1 then
                root_widget:setVisible(false)
                -- self:SetCocosLayerEnabled(root_widget, false)
            end
            ui_frame.cocos_widget[ui_name] = {}
            local ui_widget = ui_frame.cocos_widget[ui_name]

            ui_widget.root_widget = root_widget

            local function GetTheLastNode(widget_name)
                local widget_array = Lib:Split(widget_name, "/")
                local last_node = root_widget:getChildByName(widget_array[1])
                for i=2, #widget_array do
                    last_node = last_node:getChildByName(widget_array[i])
                end
                return last_node, widget_array[#widget_array]
            end

            ui_widget.widget_list = {}
            ui_widget.widget2name = {}
            local widget_list = ui_widget.widget_list
            local widget2name = ui_widget.widget2name
            local function OnTouchEvent(node, event)
                local scene = SceneMgr:GetScene(scene_name)
                local widget_name = widget2name[node]
                scene:OnCocosWidgetEvent(ui_name, widget_name, event, node)
            end

            for widget_name, resource_name in pairs(data.widget or {}) do
                local widget, real_name = GetTheLastNode(resource_name)
                if not widget or not real_name then
                    assert(false, widget_name, resource_name)
                else
                    if scene:IsHaveTouchEvent(ui_name, widget_name) == 1 then
                        widget:addTouchEventListener(OnTouchEvent)
                    end
                    widget2name[widget] = widget_name
                    widget_list[widget_name] = widget
                end
            end
            root_widget:addTouchEventListener(OnTouchEvent)
            widget2name[root_widget] = "root"
            widget_list["root"] = root_widget         
        end
    end
end

function Ui:SetCocosLayerEnabled(root_widget, is_enable)
    root_widget:setEnabled(is_enable)
end

function Ui:GetCocosLayer(ui_frame, ui_name)
    if ui_frame and ui_frame.cocos_widget 
        and ui_frame.cocos_widget[ui_name] then
        return ui_frame.cocos_widget[ui_name].root_widget
    end
end

function Ui:GetCocosWidget(ui_frame, ui_name, widget_name)
    if ui_frame and ui_frame.cocos_widget 
        and ui_frame.cocos_widget[ui_name] and ui_frame.cocos_widget[ui_name].widget_list then
        return ui_frame.cocos_widget[ui_name].widget_list[widget_name]
    end
end

function Ui:AddCocosWidget(ui_frame, ui_name, widget_name, parent_widget, widget)
    local ui_widget = ui_frame.cocos_widget[ui_name]

    local widget_list = ui_widget.widget_list
    local widget2name = ui_widget.widget2name
    
    widget2name[widget] = widget_name
    widget_list[widget_name] = widget
    parent_widget:addChild(widget)
end

function Ui:RemoveCocosWidget(ui_frame, ui_name, widget_name, parent_widget, widget)
    local ui_widget = ui_frame.cocos_widget[ui_name]

    local widget_list = ui_widget.widget_list
    local widget2name = ui_widget.widget2name
    
    widget2name[widget] = widget_name
    widget_list[widget_name] = widget
    parent_widget:addChild(widget)
end


function Ui:PopPanel(panel)
    panel:setScale(0.01)
    local scale_1 = cc.ScaleTo:create(0.1, 1.1)
    local scale_2 = cc.ScaleTo:create(0.05, 1)
    panel:runAction(cc.Sequence:create(scale_1, scale_2))
end

function Ui:PushPanel(panel, call_back)
    local action_list = {}
    action_list[#action_list + 1] = cc.ScaleTo:create(0.05, 1.1)
    action_list[#action_list + 1] = cc.ScaleTo:create(0.05, 0.01)
    if call_back then
        action_list[#action_list + 1] = cc.CallFunc:create(call_back)
    end
    panel:runAction(cc.Sequence:create(unpack(action_list)))
end