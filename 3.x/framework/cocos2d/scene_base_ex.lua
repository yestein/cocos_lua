--=======================================================================
-- File Name    : scene_base_ex.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/1 14:39:32
-- Description  :
-- Modify       :
--=======================================================================

require("framework/cocos2d/scene_base.lua")

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

function SceneBase:SetBackGroundImage(image_list, is_suit4screen)
	local main_layer = self:GetLayer("main")
	local x, y = 0, 0
	local bg_width, bg_height = 0, 0
	for _, image_file in ipairs(image_list) do
		local background = cc.Sprite:create(image_file)
		background:setAnchorPoint(cc.p(0, 0))
		background:setPosition(x, y)
		local size = background:getBoundingBox()
		if is_suit4screen == 1 then
			local scale1 = visible_size.width / size.width
			local scale2 = visible_size.height / size.height
			local scale = scale1 > scale2 and scale1 or scale2
			background:setScale(scale)
			size = background:getBoundingBox()
		end
		x = x + size.width
		if bg_height < size.height then
			bg_height = size.height
		end
		self:AddObj("main", "back_ground", image_file, background)
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
	        		SceneMgr:UnLoadCurrentScene()
	        	end,
	        },
	    },
	}	
    local menu_array = Menu:GenerateByString(element_list, 
    	{font_size = font_size or 30, align_type = "right", interval_x = 20}
    )
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    Ui:AddElement(ui_frame, "MENU", "ReturnMenu", visible_size.width, visible_size.height, menu_tools)
end

function SceneBase:AddReloadMenu(font_size)
    local element_list = {}
    if __platform == cc.PLATFORM_OS_WINDOWS then
    	local one = 
    	{
    		{
    			item_name = "重载脚本",
				callback_function = function()
					self:Reload()
				end,
			},
		}
		table.insert(element_list, one)
	end
	if SceneMgr:IsRootScene() ~= 1 then
		element_list[2] = {
			{
				item_name = "重载场景",
	        	callback_function = function()
					local scene = SceneMgr:ReloadCurrentScene()
					scene:SysMsg("场景重载完毕", "red")
	        	end,
	        },
		}
	end
    local menu_array = Menu:GenerateByString(element_list, 
    	{font_size = font_size or 30, align_type = "left", interval_x = 20}
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

function SceneBase:LoadCocosUI(json_path)
	local layer = Ui:GetLayer(self:GetUI())
	return Ui:LoadJson(layer, json_path)
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
	if self.bgm_path then
		local bgm_full_path = nil
	    if (cc.PLATFORM_OS_IPHONE == targetPlatform) or (cc.PLATFORM_OS_IPAD == targetPlatform) then
	        bgm_full_path = cc.FileUtils:getInstance():fullPathForFilename(self.bgm_path)
	    else
	        bgm_full_path = cc.FileUtils:getInstance():fullPathForFilename(self.bgm_path)
	    end
	    cc.SimpleAudioEngine:getInstance():playMusic(bgm_full_path, true)
	else
		cc.SimpleAudioEngine:getInstance():stopMusic()
	end
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