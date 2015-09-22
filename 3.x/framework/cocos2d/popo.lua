--=======================================================================
-- File Name    : popo.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2014/7/4 13:48:07
-- Description  :
-- Modify       :
--=======================================================================

if not Popo then
    Popo = NewLogicNode("Popo")
end

local defalut_font_size = 30
local defalut_lasts_seconds = 3
local dialog_tag = 1024

function Popo:_Uninit( ... )
    return 1
end

function Popo:_Init( ... )
    return 1
end

function Popo:Dialog(skelton, dialog_text, param)
    self:CloseDialog(skelton)
    self:CloseEmoj(skelton)

    local font_size  = param and param.font_size or defalut_font_size
    local font_name = param and param.font_name
    local lasts_seconds = param and param.lasts_seconds or defalut_lasts_seconds
    local background_image = param and param.image or "chat.png"

    local dialog_background = cc.Sprite:createWithSpriteFrameName(background_image)
    local rect_background = dialog_background:getTextureRect()
    local text = cc.LabelTTF:create(dialog_text, font_name, font_size)
    text:setColor(Def:GetColor("black"))
    local rect_text = text:getBoundingBox()
    local scale_x = (rect_text.width + 30) / rect_background.width
    local scale_y = (rect_text.height + 70) / rect_background.height
    dialog_background:setScaleX(scale_x)
    dialog_background:setScaleY(scale_y)

    local sprite_rect = skelton:GetBoundingBox()
    skelton:AddChildElement("dialog_bg", dialog_background, 0, sprite_rect.height + 70)
    skelton:AddChildElement("dialog_text", text, 0, sprite_rect.height + 90)

    local action_delay_time = cc.DelayTime:create(lasts_seconds)
    local action_fade_1 = CCFadeOut:create(1)
    local action_fade_2 = CCFadeOut:create(1)
    local function removeDialog()
        skelton:RemoveChildElement("dialog_bg")
        skelton:RemoveChildElement("dialog_text")
    end
    local action_remove_self = cc.CallFunc:create(removeDialog)
    dialog_background:runAction(cc.Sequence:create(action_delay_time, action_fade_1, action_remove_self))
    text:runAction(cc.Sequence:create(action_delay_time, action_fade_2, action_remove_self))
end

function Popo:CloseDialog(skelton)
    local bg = skelton:GetChildElement("dialog_bg")
    if bg then
        skelton:RemoveChildElement("dialog_bg")
    end
    local text = skelton:GetChildElement("dialog_text")
    if text then
        skelton:RemoveChildElement("dialog_text")
    end
end

function Popo:Emoj(skelton, emoj_file, param)
    self:CloseDialog(skelton)
    self:CloseEmoj(skelton)

    local emoj = skelton:GetChildElement("emoj")
    if emoj then
        skelton:RemoveChildElement("emoj")
    end

    local emoj = cc.Sprite:create("image/"..emoj_file)
    if param.scale then
        emoj:setScale(param.scale)
    end
    local emoj_rect = emoj:getBoundingBox()
    local sprite_rect = skelton:GetBoundingBox()
    skelton:AddChildElement("emoj", emoj, 0, sprite_rect.height + emoj_rect.height * 0.5)
end

function Popo:CloseEmoj(skelton)
    local emoj = skelton:GetChildElement("emoj")
    if emoj then
        skelton:RemoveChildElement("emoj")
    end
end
