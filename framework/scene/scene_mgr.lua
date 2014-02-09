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
require("script/scene/scene_base.lua")

if not SceneMgr.tb_class_logic_scene then
    SceneMgr.tb_class_logic_scene = {}
end

function SceneMgr:Init()
	self.tb_logic_scene = {}
    return 1
end

function SceneMgr:Uninit()
	self.tb_logic_scene = {}
end

function SceneMgr:OnLoop(delta)
    for str_scene_name, tb_scene in pairs(self.tb_logic_scene) do
        if tb_scene.OnLoop then
            tb_scene:OnLoop(delta)
        end
    end
end

function SceneMgr:GetScene(str_name)
	return self.tb_logic_scene[str_name]
end

function SceneMgr:GetSceneObj(str_name)
    local tb_logic_scene = self:GetScene(str_name)
    if tb_logic_scene then
        return tb_logic_scene:GetCCObj()
    end
end

function SceneMgr:GetClass(str_class_name, bool_create)
    if not SceneMgr.tb_class_logic_scene[str_class_name] and bool_create then
        local tb_class = Lib:NewClass(self._SceneBase)
        tb_class.str_class_name = str_class_name
        tb_class.tb_event_listen = {}
        SceneMgr.tb_class_logic_scene[str_class_name] = tb_class
    end
    return SceneMgr.tb_class_logic_scene[str_class_name]    
end


if _DEBUG then
    --检查是否所有的继承类都实现了该实现的方法
    function SceneMgr:CheckAllClass()

        function check(tb_class, str_function)
            if not tb_class[str_function] then
                cclog("[%s] no function[%s]", tb_class.str_class_name, str_function)
                return 0
            end
            return 1
        end

        for str_class_name, tb_class in pairs(SceneMgr.tb_class_logic_scene) do
            if check(tb_class, "_Init") ~= 1 then
                return 0
            end

            if check(tb_class, "_Uninit") ~= 1 then
                return 0
            end
        end
        return 1
    end
end

function SceneMgr:CreateScene(str_name, str_class_name)
	if self.tb_logic_scene[str_name] then
		cclog("Create Scene [%s] Failed! Already Exists", str_name)
		return
	end
    if not str_class_name then
        str_class_name = str_name
    end
    local tb_class = SceneMgr:GetClass(str_class_name)
    if not tb_class then
        return cclog("Error! No Scene Class [%s] !", str_class_name)
    end
	local tb_logic_scene = Lib:NewClass(tb_class)
    tb_logic_scene:Init(str_name)
    self.tb_logic_scene[str_name] = tb_logic_scene
	return tb_logic_scene
end

function SceneMgr:DestroyScene(str_name)
    if not self.tb_logic_scene[str_name] then
        cclog("Create Scene [%s] Failed! Not Exists", str_name)
        return
    end
    self.tb_logic_scene[str_name]:Uninit()
    self.tb_logic_scene[str_name] = nil
    return tb_logic_scene
end