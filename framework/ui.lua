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

local szTitleFontName = "MarkerFelt-Thin"
if device == "win32" then
    szTitleFontName = "Microsoft Yahei"
end

function Ui:Init()
    self.tb_ui_scene = {}
    return 1
end

function Ui:InitScene(str_scene_name, cc_scene)
    if self.tb_ui_scene[str_scene_name] then
        cclog("[%s]Already Exists", str_scene_name)
        return
    end
    
    local tb_ui = {}
	tb_ui.tb_element = {
        ["LabelTTF"] = {},
    }
    tb_ui.tb_lablettf_sysmsg = {}
    

	local tb_size_visible = CCDirector:getInstance():getVisibleSize()
	local cc_layer_ui = CCLayer:create()        

    for i = 1, Ui.MSG_MAX_COUNT do
        local cc_labelttf_sysmsg = CCLabelTTF:create("系统提示", szTitleFontName, 18)
        cc_layer_ui:addChild(cc_labelttf_sysmsg)
        local tbMsgRect = cc_labelttf_sysmsg:getTextureRect()
        cc_labelttf_sysmsg:setPosition(tb_size_visible.width / 2, tb_size_visible.height / 2 - (2 - i) * tbMsgRect.height)
        cc_labelttf_sysmsg:setVisible(false)
        tb_ui.tb_lablettf_sysmsg[i] = cc_labelttf_sysmsg
    end
    tb_ui.index_sysmsg = 1

    cc_scene:addChild(cc_layer_ui, Def.ZOOM_LEVEL_TITLE)

    tb_ui.cc_scene = cc_scene
    tb_ui.cc_layer_ui = cc_layer_ui

    self.tb_ui_scene[str_scene_name] = tb_ui
end

function Ui:UninitScene(str_scene_name)
    local tb_ui = self.tb_ui_scene[str_scene_name]
    if not tb_ui then
        cclog("[%s] Not Exitst", str_scene_name)
        return
    end
    for _, tb_type in pairs(tb_ui.tb_element) do
        for _, cc_node in pairs(tb_type) do
            tb_ui.cc_layer_ui:removeChild(cc_node, true)
        end
    end
    for _, cc_lable in pairs(tb_ui.tb_lablettf_sysmsg) do
        tb_ui.cc_layer_ui:removeChild(cc_lable, true)
    end
    tb_ui.cc_scene:removeChild(tb_ui.cc_layer_ui)

    tb_ui.tb_element = nil
    tb_ui.tb_lablettf_sysmsg = nil
    tb_ui.cc_scene = nil
    tb_ui.cc_layer_ui = nil
    self.tb_ui_scene[str_scene_name] = nil
end

function Ui:GetSceneUi(str_scene_name)
    local tb_ret = self.tb_ui_scene[str_scene_name]
    if not tb_ret then
        cclog("[%s] UI Not Exists", str_scene_name)
    end
    return tb_ret
end

function Ui:GetLayer(tb_ui)
    return tb_ui.cc_layer_ui
end

function Ui:GetTypeElement(tb_ui, str_type)
    local tb_ret = tb_ui.tb_element[str_type]
    if not tb_ret then
        assert(false)
    end
    return tb_ret
end

function Ui:AddElement(tb_ui, str_type, str_name, position_x, position_y, str_content, str_fontname, num_font_size)
    local tb_element = self:GetTypeElement(tb_ui, str_type)
    if not tb_element then
        return
    end
    if tb_element[str_name] then
        cclog("[%s][%s]Already Exists", str_type, str_name)
        return
    end
    local cc_labelttf = cc.LabelTTF:create(str_content or "", str_fontname or "Arial", num_font_size or 24);
    tb_ui.cc_layer_ui:addChild(cc_labelttf)
    if position_x and position_y then
        cc_labelttf:setPosition(position_x, position_y)
    end
    tb_element[str_name] = cc_labelttf
end

function Ui:GetElement(tb_ui, str_type, str_name)
    local tb_element = self:GetTypeElement(tb_ui, str_type)
    if not tb_element then
        return
    end
    if not tb_element[str_name] then
        cclog("[%s][%s] not Exists", str_type, str_name)
        return
    end
    return tb_element[str_name]
end

function Ui:SetText(tb_ui, str_labelttf_name, str_content)
    local cc_labelttf = self:GetElement(tb_ui, "LabelTTF", str_labelttf_name)
    if not cc_labelttf then
        assert(false)
        return
    end
    cc_labelttf:setString(str_content)
end

function Ui:SetColor(tb_ui, str_labelttf_name, str_color)
    local cc_labelttf = self:GetElement(tb_ui, "LabelTTF", str_labelttf_name)
    if not cc_labelttf then
        assert(false)
        return
    end
    cc_labelttf:setColor(str_content)
end

function Ui:SysMsg(tb_ui, szMsg, str_color)
    local tb_size_visible = CCDirector:getInstance():getVisibleSize()
    if not str_color then
        str_color = "white"
    end
    for i = 1, self.MSG_MAX_COUNT do
        local num_index = tb_ui.index_sysmsg - i + 1
        if num_index <= 0 then
            num_index = num_index + self.MSG_MAX_COUNT
        end
        local cc_labelttf_sysmsg = tb_ui.tb_lablettf_sysmsg[num_index]
        if i == 1 then
            local color = Def.tbColor[str_color]
            cc_labelttf_sysmsg:setVisible(true)
            cc_labelttf_sysmsg:setString(szMsg)
            cc_labelttf_sysmsg:setColor(color)
            cc_labelttf_sysmsg:runAction(CCFadeOut:create(3))
        end
        local tbMsgRect = cc_labelttf_sysmsg:getTextureRect()
        cc_labelttf_sysmsg:setPosition(tb_size_visible.width / 2, tb_size_visible.height / 2 + (i + 3) * tbMsgRect.height)
    end
    tb_ui.index_sysmsg = tb_ui.index_sysmsg + 1
    if tb_ui.index_sysmsg > self.MSG_MAX_COUNT then
        tb_ui.index_sysmsg = tb_ui.index_sysmsg - self.MSG_MAX_COUNT
    end
end

function Ui:LoadJson(cc_layer, str_file_name)
    local uilayer = ccs.UILayer:create()
    uilayer:addWidget(ccs.GUIReader:getInstance():widgetFromJsonFile(str_file_name))
    cc_layer:addChild(uilayer)
    return uilayer
end
