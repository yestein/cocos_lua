--=======================================================================
-- File Name    : scene_base_ex.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/1 14:39:32
-- Description  :
-- Modify       :
--=======================================================================

require("framework/cocos2d/scene_base.lua")

local OPEN_CURTAIN_TIME = 0.3
local CLOSE_CURTAIN_TIME = 0.8

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

function SceneBase:SetBackGroundImage(layer, image_list, screen_width, screen_height)
    local x, y = 0, 0
    local bg_width, bg_height = 0, 0
    if not layer then
        return x, y
    end
    for _, image_file in ipairs(image_list) do
        local background = cc.Sprite:create(image_file)
        background:setAnchorPoint(cc.p(0, 0))
        background:setPosition(x, y)
        local size = background:getBoundingBox()
        local scale_width = 1
        if screen_width == 1 then
            scale_width = visible_size.width / size.width
        end

        local scale_height = 1
        if screen_height == 1 then
            scale_height = visible_size.height / size.height
        end
        local scale = scale_width > scale_height and scale_width or scale_height
        background:setScale(scale)
        size = background:getBoundingBox()
        x = x + size.width
        if bg_height < size.height then
            bg_height = size.height
        end
        layer:addChild(background)
    end
    bg_width = x
    return bg_width, bg_height
end

function SceneBase:AddReturnMenu(font_size)
    if SceneMgr:GetRootSceneName() == self:GetName() then
        return
    end
    local element_list = {
        [1] = {
            [1] = {
                item_name = "返回上一场景",
                callback_function = function()
                    self:ReturnLastScene()
                end,
            },
        },
    }
    local menu_array = Menu:GenerateByString(element_list,
        {font_size = font_size or 30, align_type = "right", interval_x = 20, outline_color = cc.c4b(0.5, 0.5, 0.5, 1), outline_width = 2}
    )
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    Ui:AddElement(ui_frame, "MENU", "ReturnMenu", visible_size.width, visible_size.height, menu_tools)
end

function SceneBase:ReturnLastScene(story)
    local function curtainUnloadScene()
        SceneMgr:UnLoadCurrentScene()
        local scene = SceneMgr:GetCurrentScene()
        scene:UpdateSceneLayer()
        if scene:IsHaveCurtain() == 1 then
            scene:OnEnterFromPopScene()
            scene:OpenCurtain(OPEN_CURTAIN_TIME, {scene.PlayStory, scene, story})
        end
    end
    if self:IsHaveCurtain() == 1 then
        self:CloseCurtain(CLOSE_CURTAIN_TIME, {curtainUnloadScene})
    else
        curtainUnloadScene()
    end
end

function SceneBase:AddReloadMenu(font_size, is_no_reload_scene)
    local element_list = {}
    if __platform == cc.PLATFORM_OS_WINDOWS then
        local one = {
            {
                item_name = "重载脚本",
                callback_function = function()
                    self:Reload()
                end,
            },
        }
        table.insert(element_list, one)
    end
    if SceneMgr:IsRootScene() ~= 1 and is_no_reload_scene ~= 1 then
        local one = {
            {
                item_name = "重载场景",
                callback_function = function()
                    local scene = SceneMgr:ReloadCurrentScene()
                    scene:SysMsg("场景重载完毕", "red")
                end,
            },
        }
        table.insert(element_list, one)
    end

    local menu_array = Menu:GenerateByString(element_list,
        {font_size = font_size or 30, align_type = "left", interval_x = 20, outline_color = cc.c4b(0, 0, 0, 150), outline_width = 2}
    )
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    Ui:AddElement(ui_frame, "MENU", "ReloadMenu", 0, visible_size.height, menu_tools)
end

function SceneBase:Reload()
    if __platform == cc.PLATFORM_OS_WINDOWS then
        ReloadScript()
        self:SysMsg("脚本重载完毕", "red")
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

function SceneBase:LoadSoundEffect(file_path)
    if self.load_sound_effect[file_path] then
        return
    end
    Resource:LoadSoundEffect(file_path)
    self.load_sound_effect[file_path] = 1
end

function SceneBase:UnloadAllSoundEffect()
    for file_path, _ in pairs(self.load_sound_effect) do
        Resource:UnloadSoundEffect(file_path)
    end
    self.load_sound_effect = nil
end

function SceneBase:PlaySoundEffect(file_path)
    local effect_id = self.playing_effect[file_path]
    if effect_id then
        Resource:StopSoundEffect(effect_id)
    end
    self.playing_effect[file_path] = Resource:PlaySoundEffect(file_path)
end

function SceneBase:SetBGM(bgm_path)
    self.bgm_path = bgm_path
end

function SceneBase:SetBGMVolume(bgm_volume)
    self.bgm_volume = bgm_volume
end

function SceneBase:PlayBGM()
    Resource:PlayBGM(self.bgm_path)
    if self.bgm_volume then
        cc.SimpleAudioEngine:getInstance():setMusicVolume(self.bgm_volume)
    end
end

local SHAKE_ACTION_TAG = 233
function SceneBase:ShakeScreen(time, range, repeat_count, call_back)
    local layer_main = self:GetLayer("main")
    if layer_main:getActionByTag(SHAKE_ACTION_TAG) then
        return
    end
    local move_left = cc.MoveBy:create(time, cc.p(-range, 0))
    local move_right = cc.MoveBy:create(time, cc.p(range, 0))
    local action_list = {}
    for i = 1, repeat_count do
        action_list[#action_list + 1] = move_left
        action_list[#action_list + 1] = move_right
        action_list[#action_list + 1] = move_left
        action_list[#action_list + 1] = move_right
    end
    if call_back then
        local call_back_action = cc.CallFunc:create(call_back)
        action_list[#action_list + 1] = call_back_action
    end
    local shake_action = cc.Sequence:create(unpack(action_list))
    shake_action:setTag(SHAKE_ACTION_TAG)
    layer_main:runAction(shake_action)
end

function SceneBase:SetMovieBorderZOrder(z_order)
    local ui_frame = self:GetUI()
    local movie_boder_up = Ui:GetElement(ui_frame, "DRAW", "MovieBorderUp")
    assert(movie_boder_up)
    movie_boder_up:setLocalZOrder(z_order)
    local movie_boder_down = Ui:GetElement(ui_frame, "DRAW", "MovieBorderDown")
    assert(movie_boder_down)
    movie_boder_down:setLocalZOrder(z_order)
end

function SceneBase:StartMovie(time)
    local ui_frame = self:GetUI()
    local border_height = Movie:GetBorderHeight()
    local movie_boder_up = Ui:GetElement(ui_frame, "DRAW", "MovieBorderUp")
    assert(movie_boder_up)
    local move_down_action = cc.MoveTo:create(time, cc.p(0, visible_size.height - border_height))
    movie_boder_up:runAction(move_down_action)

    local movie_boder_down = Ui:GetElement(ui_frame, "DRAW", "MovieBorderDown")
    assert(movie_boder_down)
    local move_up_action = cc.MoveTo:create(time, cc.p(0, 0))
    movie_boder_down:runAction(move_up_action)
end

function SceneBase:EndMovie(time)
    local ui_frame = self:GetUI()
    local border_height = Movie:GetBorderHeight()
    local movie_boder_up = Ui:GetElement(ui_frame, "DRAW", "MovieBorderUp")
    assert(movie_boder_up)
    local move_up_action = cc.MoveTo:create(time, cc.p(0, visible_size.height))
    movie_boder_up:runAction(move_up_action)

    local movie_boder_down = Ui:GetElement(ui_frame, "DRAW", "MovieBorderDown")
    assert(movie_boder_down)
    local move_down_action = cc.MoveTo:create(time, cc.p(0, -border_height))
    movie_boder_down:runAction(move_down_action)
end

function SceneBase:MovieBorderStart(call_back, template_name, time)
    self:StartMovie(time)
    self:RegistRealTimer(math.ceil(time * GameMgr:GetFPS()), {call_back})
end

function SceneBase:MovieBorderEnd(call_back, template_name, time)
    self:EndMovie(time)

    self:RegistRealTimer(math.ceil(time * GameMgr:GetFPS()), {call_back})
end

function SceneBase:SimSlide(direction, time, speed, x, y)
    if not x then
        x = visible_size.width / 2
    end
    if not y then
        y = visible_size.height / 2
    end
    self:OnTouchBegan(x, y)

    local function simTouch(rest_count)
        if direction == "left" then
            x = x - speed
        elseif direction == "right" then
            x = x + speed
        elseif direction == "up" then
            y = y + speed
        elseif direction == "down" then
            y = y - speed
        end
        if rest_count <= 0 then
            self:OnTouchEnded(x, y)
            self.is_move = nil
        else
            self.is_move = 1
            self:OnTouchMoved(x, y)
        end
    end
    RealTimer:RegistCocosTimerByCount(math.floor(time / cc.Director:getInstance():getAnimationInterval()), 0, {simTouch})
end

function SceneBase:InitCurtain(left_image, right_image, is_hide)
    local ui_frame = self:GetUI()
    local left = cc.Sprite:create(left_image)
    left:setAnchorPoint(cc.p(1, 0))
    left:setPosition(visible_size.width * 0.5, 0)
    local right = cc.Sprite:create(right_image)
    right:setAnchorPoint(cc.p(0, 0))
    right:setPosition(visible_size.width * 0.5, 0)

    self.is_have_curtain = 1

    local layer = self:CreateLayer("curtain", 10000)
    self:AddObj("curtain", "IMAGE", "left_curtain", left)
    self:AddObj("curtain", "IMAGE", "right_curtain", right)
    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end
    layer:registerScriptTouchHandler(onTouchEvent)
    layer:setTouchEnabled(true)
    if is_hide == 1 then
        left:setPosition(0, 0)
        right:setPosition(visible_size.width, 0)
        layer:setTouchEnabled(false)
    end
end

function SceneBase:IsHaveCurtain()
    return self.is_have_curtain
end

function SceneBase:ResetCurtain()
    local layer = self:GetLayer("curtain")
    layer:setTouchEnabled(false)
    self.is_opening_curtain = nil
    self.is_close_curtain = nil
    local left = self:GetObj("curtain", "IMAGE", "left_curtain")
    local right = self:GetObj("curtain", "IMAGE", "right_curtain")
    left:stopAllActions()
    left:setPosition(cc.p(0, 0))
    right:stopAllActions()
    right:setPosition(cc.p(visible_size.width, 0))
end

function SceneBase:OpenCurtain(time, call_back)
    if self.is_opening_curtain then
        return
    end
    local layer = self:GetLayer("curtain")
    layer:setTouchEnabled(true)
    self.is_opening_curtain = 1
    local left = self:GetObj("curtain", "IMAGE", "left_curtain")
    local right = self:GetObj("curtain", "IMAGE", "right_curtain")

    local left_action_list = {}
    left_action_list[#left_action_list + 1] = cc.MoveTo:create(time, cc.p(0, 0))
    local function actionEnd()
        self.is_opening_curtain = nil
        layer:setTouchEnabled(false)
        if call_back then
            Lib:SafeCall(call_back)
        end
    end
    left_action_list[#left_action_list + 1] = cc.CallFunc:create(actionEnd)
    left:stopAllActions()
    left:runAction(cc.Sequence:create(unpack(left_action_list)))
    right:stopAllActions()
    right:runAction(cc.MoveTo:create(time, cc.p(visible_size.width, 0)))
end

function SceneBase:CloseCurtain(time, call_back)
    if self.is_close_curtain then
        return
    end
    local layer = self:GetLayer("curtain")
    layer:setTouchEnabled(true)
    self.is_close_curtain = 1
    local left = self:GetObj("curtain", "IMAGE", "left_curtain")
    local right = self:GetObj("curtain", "IMAGE", "right_curtain")

    local left_action_list = {}
    left_action_list[#left_action_list + 1] = cc.EaseBounceOut:create(cc.MoveTo:create(time, cc.p(visible_size.width * 0.5, 0)))
    left_action_list[#left_action_list + 1] = cc.DelayTime:create(0.5)

    local function actionEnd()
        self.is_close_curtain = nil
        if call_back then
            Lib:SafeCall(call_back)
        end
    end
    left_action_list[#left_action_list + 1] = cc.CallFunc:create(actionEnd)
    left:runAction(cc.Sequence:create(unpack(left_action_list)))

    local right_action_list = {}
    right_action_list[#right_action_list + 1] = cc.EaseBounceOut:create(cc.MoveTo:create(time, cc.p(visible_size.width * 0.5, 0)))
    right_action_list[#right_action_list + 1] = cc.DelayTime:create(0.5)
    right:runAction(cc.Sequence:create(unpack(right_action_list)))
end

function SceneBase:AddMask(name, color, level, pop_panel_name)
    local layer_color = cc.LayerColor:create(color, visible_size.width + 100, visible_size.height + 50)
    layer_color:setLocalZOrder(level)
    layer_color:setTouchEnabled(true)

    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "ended" then
            if pop_panel_name then
                local pop_panel = Ui:GetCocosLayer(self:GetUI(), pop_panel_name)
                pop_panel:setVisible(false)
                self:RemoveMask(name)
            end
        end
    end

    if pop_panel_name then
        local pop_panel = Ui:GetCocosLayer(self:GetUI(), pop_panel_name)
        pop_panel:setTouchEnabled(false)
    end
    layer_color:setTouchMode(1)
    layer_color:registerScriptTouchHandler(onTouchEvent)

    self:AddLayer(name, layer_color)
end

function SceneBase:RemoveMask(name)
    self:RemoveLayer(name)
end

function SceneBase:OpenNetProcess()
    local layer_name = "net_process"
    local layer_color = self:GetLayer(layer_name)
    if layer_color then
        layer_color:setVisible(true)
        return
    end
    layer_color = cc.LayerColor:create(cc.c4b(0, 0, 0, 0), visible_size.width + 100, visible_size.height + 50)
    layer_color:setLocalZOrder(99999)
    layer_color:setTouchEnabled(true)

    self:AddLayer(layer_name, layer_color)

    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return true
        end
    end

    layer_color:setTouchMode(1)
    layer_color:registerScriptTouchHandler(onTouchEvent)

    local cc_process_sprite = cc.Sprite:create("image/circle_process.png")
    cc_process_sprite:setPosition(visible_size.width / 2, visible_size.height / 2)
    cc_process_sprite:setVisible(false)
    layer_color:addChild(cc_process_sprite)

    local function call_back()
        cc_process_sprite:setVisible(true)
        cc_process_sprite:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.5, 180)))
    end

    local acition_list = {}
    acition_list[#acition_list + 1] = cc.DelayTime:create(0.5)
    acition_list[#acition_list + 1] = cc.CallFunc:create(call_back)
    cc_process_sprite:runAction(cc.Sequence:create(unpack(acition_list)))
end

function SceneBase:CloseNetProcess()
    self:RemoveLayer("net_process")
end

function SceneBase:TryOpenDebug(x, y)
    local function OverTime()
        self.try_open_debug = nil
        self.try_close_debug = nil
    end
    if x < 200 then
        if y < 200 then
            self.try_open_debug = 1
            self:RegistRealTimerBySeconds(1, {OverTime})
        elseif y > visible_size.height - 200 then
            self.try_close_debug = 1
            self:RegistRealTimerBySeconds(1, {OverTime})
        end
    end
end

function SceneBase:CheckCanOpenDebug(x, y)
    if self.try_open_debug == 1 then
        if (x > visible_size.width - 200) and y > (visible_size.height - 200) then
            self:OpenDebugAssert()
        end
        self.try_open_debug = nil
    end
    if self.try_close_debug == 1 then
        if (x > visible_size.width - 200) and y < 200 then
            self:CloseDebugAssert()
        end
        self.try_close_debug = nil
    end
end

function SceneBase:UpdateDebugAssert()
    if not self:GetLayer("debug_assert") then
        self:OpenDebugAssert()
    else
        local label = self:GetObj("debug_assert", "debug", "assert")
        local msg = string.format(">>BEGIN\n%s\n>>END", Debug:GetRecordMsg())
        label:setString(msg)
        local rect = label:getBoundingBox()
        label:setPosition(0, rect.height)
    end
end

function SceneBase:OpenDebugAssert()
    self:AddMask("debug_assert", cc.c4b(0, 0, 0, 220), 4)
    local msg = string.format(">>BEGIN\n%s\n>>END", Debug:GetRecordMsg())
    local label = cc.Label:createWithSystemFont(msg, "", 20, cc.size(visible_size.width, 0))
    LabelEffect:EnableOutline(label, cc.c3b(255, 255, 255), cc.c3b(0.5, 0.5, 0.5, 1), 1)
    label:setAnchorPoint(0, 1)
    local rect = label:getBoundingBox()
    label:setPosition(0, rect.height)
    self:AddObj("debug_assert", "debug", "assert", label)

    local element_list = {
        [1] = {
            {
                item_name = "上移",
                callback_function = function()
                    self:MoveDebugMsg(0, -100)
                end,
            },
        },
        [2] = {
            {
                item_name = "下移",
                callback_function = function()
                    self:MoveDebugMsg(0, 100)
                end,
            },
        },
        [3] = {
            {
                item_name = "关闭",
                callback_function = function()
                    self:CloseDebugAssert()
                end,
            },
        },
    }
    local menu_array = Menu:GenerateByString(element_list,
        {font_size = font_size or 30, align_type = "right", interval_y = 40, outline_color = cc.c4b(0.5, 0.5, 0.5, 1), outline_width = 2}
    )
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    menu_tools:setPosition(visible_size.width, visible_size.height - 200)
       self:AddObj("debug_assert", "debug", "close", menu_tools)
end

function SceneBase:MoveDebugMsg(x, y)
    local label = self:GetObj("debug_assert", "debug", "assert")
    local old_x, old_y = label:getPosition()
    local rect = label:getBoundingBox()
    if rect.height < visible_size.height then
        return
    end
    local new_x, new_y = old_x, old_y + y
    if new_y > rect.height then
        new_y = rect.height
    end
    if new_y < visible_size.height then
        new_y = visible_size.height
    end
    label:setPosition(new_x, new_y)
end

function SceneBase:CloseDebugAssert()
    if self:GetLayer("debug_assert") then
        self:RemoveLayer("debug_assert")
    end
end

function SceneBase:PlayStory(story_id, callback)
    if not story_id then
        return
    end
    StoryMgr:PlayStory(self, story_id, callback)
end

function SceneBase:UpdateSceneLayer()

   return
end
