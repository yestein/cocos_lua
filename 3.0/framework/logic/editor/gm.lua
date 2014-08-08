--=======================================================================
-- File Name    : gm.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sun May 11 22:28:16 2014
-- Description  :
-- Modify       :
--=======================================================================

if not GM then
	GM = ModuleMgr:NewModule("GM")
end

function GM:_Uninit()
	self.actions = nil
	return 1
end

function GM:_Init()
	self.actions = {}
	self:CreateCommonActions()

	return 1
end

function GM:RecieveEvent(event_type, action_list)
	for _, action in ipairs(action_list) do
		self:ExecuteAction(action[1], unpack(action, 2))
	end
end

function GM:ExecuteAction(action_name, ...)
	local func = self.actions[action_name]
	assert(func)
	func(...)
end

function GM:AddAction(action_name, func)
	if self.actions[action_name] then
		print("Action [" .. action_name .. "] Already Exist!")
	end
	assert(not self.actions[action_name])
	self.actions[action_name] = func
end

function GM:ParseEventData(event_handle)
	for event_type, action_list in pairs(event_handle) do
		local function_name = "On"..event_type	
		GM[function_name] = function(self)
			GM:RecieveEvent(event_type, action_list)
		end
		GM:DeclareListenEvent(event_type, function_name)
	end
end

function GM:CreateCommonActions()

	GM:AddAction("FireEvent", 
		function(event_type)
			Event:FireEvent(event_type)
		end
	)

	GM:AddAction("LoadScene", 
		function(scene_name)
			Scene:LoadScene(scene_name)
		end
	)

	GM:AddAction("PopScene", 
		function()
			SceneMgr:UnLoadCurrentScene()
		end
	)

	GM:AddAction("CreateMenu",
		function(menu_name, align_type, font_size, x, y, action_list)
			local scene = SceneMgr:GetCurrentScene()
			if not scene then
				return
			end
			local ui = scene:GetUI()
			local spec_menu = Ui:GetElement(ui, "MENU", menu_name)
			if spec_menu then
				Ui:RemoveElement(ui, "MENU", menu_name)
			end
			local element_list = {[1] = {}}
			for _, action_one in ipairs(action_list) do
				local item = {
					item_name = action_one[1],
					callback_function = function()
						GM:ExecuteAction(action_one[2], unpack(action_one, 3))
					end,
				}
				table.insert(element_list[1], item)
			end
			local menu_array, width, height = Menu:GenerateByString(element_list, {align_type = align_type, font_size = font_size})
			local menu = cc.Menu:create(unpack(menu_array))
			Ui:AddElement(ui, "MENU", menu_name, visible_size.width * x, visible_size.height * y, menu)
		end
	)

	GM:AddAction("Confirm", 
		function(actions)
			local scene = SceneMgr:GetCurrentScene()
			if not scene then
				return
			end
			local ui = scene:GetUI()
			local confirm = Ui:GetElement(ui, "MENU", "CONFIRM")
			if confirm then
				Ui:RemoveElement(ui, "MENU", "CONFIRM")
			end
			local element_list = {
				{
					{
						item_name = "是",
						callback_function = function()
							for _, action in ipairs(actions) do
								GM:ExecuteAction(action[1], unpack(action, 2))
							end
							Ui:RemoveElement(ui, "MENU", "CONFIRM")
						end,
					},
					{
						item_name = "否",
						callback_function = function()
							Ui:RemoveElement(ui, "MENU", "CONFIRM")
						end,
					},
				},
			}
			local menu_array, width, height = Menu:GenerateByString(element_list, {align_type = "center", font_size = 40, interval_x = 40})
			local menu = cc.Menu:create(unpack(menu_array))
			Ui:AddElement(ui, "MENU", "CONFIRM", visible_size.width / 2, visible_size.height / 2, menu)
		end
	)

	GM:AddAction("CreateLabel", 
		function(label_name, text, font_size, x, y)
			local scene = SceneMgr:GetCurrentScene()
			if not scene then
				return
			end
			local ui = scene:GetUI()
			local label_text = Ui:GetElement(ui, "LabelTTF", label_name)
			if label_text then
				Ui:RemoveElement(ui, "MENU", label_name)
			end
			label_text = cc.LabelTTF:create(text, nil, font_size)
			Ui:AddElement(ui, "LabelTTF", label_name, visible_size.width * x, visible_size.height * y, label_text)
		end
	)

	GM:AddAction("RemoveElement", 
		function(element_type, element_name)
			local scene = SceneMgr:GetCurrentScene()
			if not scene then
				return
			end
			local ui = scene:GetUI()
			Ui:RemoveElement(ui, element_type, element_name)
		end
	)
end

