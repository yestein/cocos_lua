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

function SceneMgr:Init()
    self.current_scene_list = {}
	self.scene_list = {}
    return 1
end

function SceneMgr:Uninit()
    for scene_name, scene in pairs(self.scene_list) do
        scene:_Uninit()
    end
    self.current_scene_list = nil
	self.scene_list = {}
end

function SceneMgr:OnLoop(delta)
    for scene_name, scene in pairs(self.scene_list) do
        if scene.OnLoop then
            scene:OnLoop(delta)
        end
    end
end

function SceneMgr:GetScene(scene_name)
	return self.scene_list[scene_name]
end

function SceneMgr:GetSceneObj(scene_name)
    local scene = self:GetScene(scene_name)
    if scene then
        return scene:GetCCObj()
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
	if self.scene_list[scene_name] then
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
	local scene = Lib:NewClass(scene_template)
    self.scene_list[scene_name] = scene
    scene:Init(scene_name)
	return scene
end

function SceneMgr:DestroyScene(scene_name)
    if not self.scene_list[scene_name] then
        cclog("Create Scene [%s] Failed! Not Exists", scene_name)
        return
    end
    local delete_index = nil
    for index, name in ipairs(self.current_scene_list) do
        if name == scene_name then
            delete_index = index
            break
        end
    end
    if delete_index then
        table.remove(self.current_scene_list, delete_index)
    end
    self.scene_list[scene_name]:Uninit()
    self.scene_list[scene_name] = nil
    return scene_list
end

function SceneMgr:FirstLoadScene(scene_name)
    local scene = self:GetScene(scene_name)
    if not scene then
        scene = self:CreateScene(scene_name, scene_name)
    end

    table.insert(self.current_scene_list, scene:GetName())
    local cc_scene = scene:GetCCObj()
    CCDirector:getInstance():runWithScene(cc_scene)
end

function SceneMgr:LoadScene(scene_name)
    local scene = self:GetScene(scene_name)
    if not scene then
        scene = self:CreateScene(scene_name, scene_name)
    end

    table.insert(self.current_scene_list, scene:GetName())
    local cc_scene = scene:GetCCObj()
    CCDirector:getInstance():pushScene(cc_scene)
    return scene
end

function SceneMgr:GetCurrentSceneName()
    local count = #self.current_scene_list
    if count > 0 then
        return self.current_scene_list[count]
    end
end

function SceneMgr:UnLoadCurrentScene()
    local current_scene_name = self:GetCurrentSceneName()
    self:DestroyScene(current_scene_name)
    CCDirector:getInstance():popScene()
end