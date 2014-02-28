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

Ui.MSG_MAX_COUNT = 3

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
        ["LabelTTF"] = {},
    }
    ui_frame.sysmsg_list = {}
    

	local cc_layer_ui = CCLayer:create()        

    for i = 1, Ui.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = CCLabelTTF:create("系统提示", title_font_name, 18)
        cc_layer_ui:addChild(cc_labelttf_sysmsg)
        local tbMsgRect = cc_labelttf_sysmsg:getTextureRect()
        cc_labelttf_sysmsg:setPosition(visible_size.width / 2, visible_size.height / 2 - (2 - i) * tbMsgRect.height)
        cc_labelttf_sysmsg:setVisible(false)
        ui_frame.sysmsg_list[i] = cc_labelttf_sysmsg
    end
    ui_frame.index_sysmsg = 1

    cc_scene:addChild(cc_layer_ui, SceneMgr.ZOOM_LEVEL_TITLE)

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

function Ui:AddElement(ui_frame, element_type, element_name, position_x, position_y, text_content, str_fontname, num_font_size)
    local element_list = self:GetTypeElement(ui_frame, element_type)
    if not element_list then
        return
    end
    if element_list[element_name] then
        cclog("[%s][%s]Already Exists", element_type, element_name)
        return
    end
    local cc_labelttf = cc.LabelTTF:create(text_content or "", str_fontname or "Arial", num_font_size or 24);
    ui_frame.cc_layer_ui:addChild(cc_labelttf)
    if position_x and position_y then
        cc_labelttf:setPosition(position_x, position_y)
    end
    element_list[element_name] = cc_labelttf
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

function Ui:SetText(ui_frame, labelttf_name, text_content)
    local cc_labelttf = self:GetElement(ui_frame, "LabelTTF", labelttf_name)
    if not cc_labelttf then
        assert(false)
        return
    end
    cc_labelttf:setString(text_content)
end

function Ui:SetColor(ui_frame, labelttf_name, color_name)
    local cc_labelttf = self:GetElement(ui_frame, "LabelTTF", labelttf_name)
    if not cc_labelttf then
        assert(false)
        return
    end
    cc_labelttf:setColor(Def.color_list[color_name])
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
        local tbMsgRect = cc_labelttf_sysmsg:getTextureRect()
        cc_labelttf_sysmsg:setPosition(visible_size.width / 2, visible_size.height - (self.MSG_MAX_COUNT - i + 1) * tbMsgRect.height)
    end
    ui_frame.index_sysmsg = ui_frame.index_sysmsg + 1
    if ui_frame.index_sysmsg > self.MSG_MAX_COUNT then
        ui_frame.index_sysmsg = ui_frame.index_sysmsg - self.MSG_MAX_COUNT
    end
end

function Ui:LoadJson(cc_layer, json_file_path)
    local ui_layer = ccs.UILayer:create()
    ui_layer:addWidget(ccs.GUIReader:getInstance():widgetFromJsonFile(json_file_path))
    cc_layer:addChild(ui_layer)
    return ui_layer
end
