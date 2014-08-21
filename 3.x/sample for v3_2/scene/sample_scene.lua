--=======================================================================
-- File Name    : sample_scene.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : Sat Aug  9 18:07:07 2014
-- Description  :
-- Modify       :
--=======================================================================

local Scene = SceneMgr:GetClass("Sample", 1)
Scene.property = {
	can_touch = 1,
	can_drag = 1,
	limit_drag = 1,
}

function Scene:MainSample()
	local element_list = {
 		{
	    	{
				item_name = "scene sample",
	        	callback_function = function()
	        		self:SceneSample()
	        	end,
	        },
	    },
	}
	

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 40, align_type = "center", interval_x = 50, interval_y = 20}
    )
    if height > visible_size.height then
    	self:SetHeight(height)
    end
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "Welcome")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "Welcome")
    end
    Ui:AddElement(ui_frame, "MENU", "Welcome", visible_size.width / 2, visible_size.height / 2 + height / 2, menu_tools)
    return 1
end

function Scene:SceneSample()
	local element_list = {
 		{
	    	{
				item_name = "drag",
	        	callback_function = function()
	        		SceneMgr:LoadScene("SampleUnlimitDrag", "Sampel1")
	        	end,
	        },
	    },
	    {
	    	{
				item_name = "drag with limit",
	        	callback_function = function()
	        		SceneMgr:LoadScene("SampleLimitDrag", "Sampel2")
	        	end,
	        },
	    },
	    {
	    	{
				item_name = "background music",
	        	callback_function = function()
	        		SceneMgr:LoadScene("SampleBGM", "Sampel3")
	        	end,
	        },
	    },
	    {
	    	{
				item_name =  "multi background image",
	        	callback_function = function()
	        		SceneMgr:LoadScene("SampleBackground", "Sampel4")
	        	end,
	        },
	    },
	    {
	    	{
				item_name =  "Return",
	        	callback_function = function()
	        		self:MainSample()
	        	end,
	        },
	    },
	}
	

    local menu_array, width, height = Menu:GenerateByString(element_list, 
    	{font_size = 40, align_type = "center", interval_x = 50, interval_y = 20}
    )
    if height > visible_size.height then
    	self:SetHeight(height)
    end
    local ui_frame = self:GetUI()
    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "Welcome")
    if exist_menu then
    	Ui:RemoveElement(ui_frame, "MENU", "Welcome")
    end
    Ui:AddElement(ui_frame, "MENU", "Welcome", visible_size.width / 2, visible_size.height / 2 + height / 2, menu_tools)
end

function Scene:_Init()
	self:AddReturnMenu()
	self:AddReloadMenu()
	self:MainSample()
    return 1
end