--=======================================================================
-- File Name    : scene_list.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/9/29 13:58:29
-- Description  : sample Scene to show list of scene
-- Modify       :
--=======================================================================
local Scene = SceneMgr:GetClass("SceneList", 1)
Scene.property = {
    can_touch = 1,
}

function Scene:_Init()
    self:AddReloadMenu(50)
    self:AddReturnMenu(50)
    return 1
end

function Scene:OnTouchBegan(x, y)
    self.touch_begin = {x, y}
end

function Scene:OnTouchMoved(x, y)
    if self.menu_welcom_height < visible_size.height then
        return
    end

    local begin_x, bgein_y = unpack(self.touch_begin)
    local distance_y = y - bgein_y
    self.touch_begin[1], self.touch_begin[2] = x, y

    local menu = Ui:GetElement(self:GetUI(), "MENU", "SceneList")
    local menu_x, menu_y = menu:getPosition()
    menu_y = menu_y + distance_y
    if menu_y > self.menu_welcom_height + 50 then
        menu_y = self.menu_welcom_height + 50
    elseif menu_y < visible_size.height - 50 then
        menu_y = visible_size.height - 50
    end
    menu:setPosition(menu_x, menu_y)

end

function Scene:OnTouchEnded(x, y)
    self.touch_begin = nil
end

--[[
Param 'scene_list' should like this below:

scene_list = {
    {
        case_name = show name,
        stage_name = scene name,
        data = {
            template_scene = template_name,
            ...
        },
    },
    ...
}
--]]
function Scene:ShowSceneList(scene_list)
    local ui_frame = self:GetUI()

    local element_list = {}
    for _, scene_list in ipairs(scene_list) do
        local element = {
            {
                item_name = scene_list.case_name or scene_list.stage_name .. "(?)",
                callback_function = function ()
                    SceneMgr:LoadScene(scene_list.data.template_scene, scene_list.stage_name)
                end,
            },
        }
        element_list[#element_list + 1] = element
    end

    local menu_array, width, height = Menu:GenerateByString(element_list,
        {font_size = 50, align_type = "center", interval_x = 50, interval_y = 20}
    )

    local menu_tools = cc.Menu:create(unpack(menu_array))
    local exist_menu = Ui:GetElement(ui_frame, "MENU", "SceneList")
    if exist_menu then
        Ui:RemoveElement(ui_frame, "MENU", "SceneList")
    end
    local x, y = visible_size.width / 2, visible_size.height / 2 + height / 2
    if height > visible_size.height - 50 then
        y = visible_size.height - 50
    end
    Ui:AddElement(ui_frame, "MENU", "SceneList", x, y, menu_tools)
    self.menu_welcom_height = height
end
