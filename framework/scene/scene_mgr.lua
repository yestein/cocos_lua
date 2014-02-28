--=======================================================================
-- File Name    : scene_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

if not SceneMgr then
    SceneMgr = {}
end

if not SceneMgr.scene_class_list then
    SceneMgr.scene_class_list = {}
end

SceneMgr.ZOOM_LEVEL_WORLD = 1
SceneMgr.ZOOM_LEVEL_TITLE = 3
SceneMgr.ZOOM_LEVEL_MENU = 5

function SceneMgr:Init()
	self.logic_scene_list = {}
    return 1
end

function SceneMgr:Uninit()
	self.logic_scene_list = {}
end

function SceneMgr:OnLoop(delta)
    for scene_name, logic_scene in pairs(self.logic_scene_list) do
        if logic_scene.OnLoop then
            logic_scene:OnLoop(delta)
        end
    end
end

function SceneMgr:GetScene(scene_name)
	return self.logic_scene_list[scene_name]
end

function SceneMgr:GetSceneObj(scene_name)
    local logic_scene_list = self:GetScene(scene_name)
    if logic_scene_list then
        return logic_scene_list:GetCCObj()
    end
end

function SceneMgr:GetClass(class_name, is_need_create)
    if not SceneMgr.scene_class_list[class_name] and is_need_create then
        local scene_class = Lib:NewClass(self._SceneBase)
        scene_class.class_name = class_name
        scene_class.event_listener = {}
        SceneMgr.scene_class_list[class_name] = scene_class
    end
    return SceneMgr.scene_class_list[class_name]    
end


if _DEBUG then
    --检查是否所有的继承类都实现了该实现的方法
    function SceneMgr:CheckAllClass()

        function check(scene_class, fun_name)
            if not scene_class[fun_name] then
                cclog("[%s] no function[%s]", scene_class.str_class_name, fun_name)
                return 0
            end
            return 1
        end

        for str_class_name, scene_class in pairs(SceneMgr.scene_class_list) do
            if check(scene_class, "_Init") ~= 1 then
                return 0
            end

            if check(scene_class, "_Uninit") ~= 1 then
                return 0
            end
        end
        return 1
    end
end

function SceneMgr:CreateScene(scene_name, scene_template_name)
	if self.logic_scene_list[scene_name] then
		cclog("Create Scene [%s] Failed! Already Exists", scene_name)
		return
	end
    if not scene_template_name then
        scene_template_name = scene_name
    end
    local scene_template = SceneMgr:GetClass(scene_template_name)
    if not scene_template then
        return cclog("Error! No Scene Class [%s] !", scene_template_name)
    end
	local logic_scene_list = Lib:NewClass(scene_template)
    self.logic_scene_list[scene_name] = logic_scene_list
    logic_scene_list:Init(scene_name)
	return logic_scene_list
end

function SceneMgr:DestroyScene(scene_name)
    if not self.logic_scene_list[scene_name] then
        cclog("Create Scene [%s] Failed! Not Exists", scene_name)
        return
    end
    self.logic_scene_list[scene_name]:Uninit()
    self.logic_scene_list[scene_name] = nil
    return logic_scene_list
end