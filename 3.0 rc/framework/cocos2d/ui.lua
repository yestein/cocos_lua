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

Ui.MSG_MAX_COUNT = 7

--keep same with "cocos\gui\UIWidget.h"
Ui.TOUCH_EVENT_BEGAN    = 0
Ui.TOUCH_EVENT_MOVED    = 1
Ui.TOUCH_EVENT_ENDED    = 2
Ui.TOUCH_EVENT_CANCELED = 3

local title_font_name = "MarkerFelt-Thin"
if device == "win32" then
    title_font_name = "Microsoft Yahei"
end
local visible_size = CCDirector:getInstance():getVisibleSize()

function Ui:Uninit()
    self.scene_ui_list = {}
    return 1
end

function Ui:Init()
    self.scene_ui_list = {}
    return 1
end

function Ui:InitScene(scene_name, cc_scene)
    if self.scene_ui_list[scene_name] then
        cclog("[%s]Already Exists", scene_name)
        return
    end
    
    local ui_frame = {}
	ui_frame.element_list = {
        ["Menu"] = {},
        ["LabelTTF"] = {},
        ["LabelBMFont"] = {},
        ["Label"] = {},
    }
    ui_frame.sysmsg_list = {}
    

	local cc_layer_ui = CCLayer:create()        

    for i = 1, Ui.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = CCLabelTTF:create("系统提示", title_font_name, 18)
        cc_layer_ui:addChild(cc_labelttf_sysmsg)
        cc_labelttf_sysmsg:setLocalZOrder(Def.ZOOM_LEVEL_SYSMSG)
        local tbMsgRect = cc_labelttf_sysmsg:getBoundingBox()
        cc_labelttf_sysmsg:setPosition(visible_size.width / 2, visible_size.height / 2 - (2 - i) * tbMsgRect.height)
        cc_labelttf_sysmsg:setVisible(false)
        ui_frame.sysmsg_list[i] = cc_labelttf_sysmsg
    end
    ui_frame.index_sysmsg = 1

    cc_scene:addChild(cc_layer_ui, Def.ZOOM_LEVEL_TITLE)

    ui_frame.cc_scene = cc_scene
    ui_frame.cc_layer_ui = cc_layer_ui



    self.scene_ui_list[scene_name] = ui_frame

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
    local tb_ret = ui_frame.element_list[element_type]
    if not tb_ret then
        assert(false)
    end
    return tb_ret
end

function Ui:AddElement(ui_frame, element_type, element_name, position_x, position_y, element)
    local element_list = self:GetTypeElement(ui_frame, element_type)
    if not element_list then
        return
    end
    if element_list[element_name] then
        cclog("[%s][%s]Already Exists", element_type, element_name)
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
        cclog("[%s][%s] not Exists", element_type, element_name)
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
    tu_ui.cc_layer_ui:removeChiled(element_list[element_name], true)
    element_list[element_name] = nil
end

function Ui:SetVisible(ui_frame, element_type, element_name, is_visible)
    local element = self:GetElement(ui_frame, element_type, element_name)
    element:setVisible(is_show)
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
            cc_labelttf_sysmsg:setVisible(true)
            cc_labelttf_sysmsg:setString(text_content)
            cc_labelttf_sysmsg:setColor(color)
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
    return root_widget, root_widget
end

function Ui:PreloadCocosUI(scene_name, ui_list)
    local ui_frame = self:GetSceneUi(scene_name)
    if ui_list and ui_frame then
        if not ui_frame.cocos_widget then
            ui_frame.cocos_widget = {}
        end
        local layer = self:GetLayer(ui_frame)
        for ui_file, data in pairs(ui_list) do
            local root_widget, root_widget = self:LoadJson(layer, ui_file)
            local widget_rect = root_widget:getSize()
            root_widget:setScaleX(visible_size.width / widget_rect.width)
            root_widget:setScaleY(visible_size.height / widget_rect.height)
            if data.hide == 1 then
                root_widget:setVisible(false)
                self:SetCocosLayerEnabled(root_widget, false)
            end
            local ui_name = data.name
            ui_frame.cocos_widget[ui_name] = {}
            ui_frame.cocos_widget[ui_name].root_widget = root_widget
            local button_list = data.button
            ui_frame.cocos_widget[ui_name].button = {}
            ui_frame.cocos_widget[ui_name].widget2button = {}
            local button_widget_list = ui_frame.cocos_widget[ui_name].button
            local widget2button = ui_frame.cocos_widget[ui_name].widget2button

            local function OnButtonEvent(node, event)
                local widget_button = tolua.cast(node, "ccui.Button")
                local scene = SceneMgr:GetScene(scene_name)
                local button_name = widget2button[widget_button:getName()]
                if scene.OnCocosButtonEvent then
                    scene:OnCocosButtonEvent(ui_name, button_name, event)
                end
            end
            for button_name, widget_name in pairs(button_list) do
                 local widget_button = root_widget:getChildByName(widget_name)
                 assert(widget2button)
                 widget_button:addTouchEventListener(OnButtonEvent)
                 widget2button[widget_name] = button_name
                 button_widget_list[button_name] = tolua.cast(widget_button, "ccui.Button")
            end

            local labelbmfont_list = data.labelbmfont
            ui_frame.cocos_widget[ui_name].labelbmfont = {}
            ui_frame.cocos_widget[ui_name].widget2labelbmfont = {}
            local labelbmfont_widget_list = ui_frame.cocos_widget[ui_name].labelbmfont
            local widget2labelbmfont = ui_frame.cocos_widget[ui_name].widget2labelbmfont
            for labelbmfont_name, widget_name in pairs(labelbmfont_list) do
                 local widget_labelbmfont = root_widget:getChildByName(widget_name)
                 assert(widget_labelbmfont)
                 widget2labelbmfont[widget_name] = labelbmfont_name
                 labelbmfont_widget_list[labelbmfont_name] = tolua.cast(widget_labelbmfont, "UILabelBMFont")
            end

            local ui_widget = ui_frame.cocos_widget[ui_name]
            ui_widget.label = {}
            ui_widget.widget2label = {}
            for label_name, widget_name in pairs(data.label or {}) do
                ui_widget.label[label_name] = tolua.cast(assert(root_widget:getChildByName(widget_name)), "UILabel")
                ui_widget.widget2label[widget_name] = label_name
            end
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

function Ui:GetCocosButton(ui_frame, ui_name, button_name)
    if ui_frame and ui_frame.cocos_widget 
        and ui_frame.cocos_widget[ui_name] and ui_frame.cocos_widget[ui_name].button then
        return ui_frame.cocos_widget[ui_name].button[button_name]
    end
end

function Ui:GetCocosLabelbmfont(ui_frame, ui_name, labelbmfont_name)
    if ui_frame and ui_frame.cocos_widget 
        and ui_frame.cocos_widget[ui_name] and ui_frame.cocos_widget[ui_name].labelbmfont then
        return ui_frame.cocos_widget[ui_name].labelbmfont[labelbmfont_name]
    end
end

function Ui:GetCocosLabel(ui_frame, ui_name, label_name)
    if ui_frame and ui_frame.cocos_widget 
        and ui_frame.cocos_widget[ui_name] and ui_frame.cocos_widget[ui_name].label then
        return ui_frame.cocos_widget[ui_name].label[label_name]
    end
end