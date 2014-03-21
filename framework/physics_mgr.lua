--=======================================================================
-- File Name    : physics_mgr.lua
-- Creator      : yestein (yestein86@gmail.com)
-- Date         : 2014-1-18
-- Description  :
-- Modify       :
--=======================================================================
if not Physics then
	Physics = {}
end

local tb_plist = {
	"physics/map.plist",
}

-- 默认物理世界重力
local DEFAULT_GRAVITY = {0, -20}


local PhysicsWorld = nil
if GamePhysicsWorld then
	PhysicsWorld = GamePhysicsWorld:GetInstance()
end

function Physics:Uninit()
end

function Physics:Init()
	if not PhysicsWorld then
		return
	end
	if PhysicsWorld:Init(unpack(DEFAULT_GRAVITY)) ~= 1 then
		return 0
	end
	if self:LoadPList() ~= 1 then
		return 0
	end
	return 1
end

function Physics:LoadPList()
	if not PhysicsWorld then
		return 0
	end
	for _, str_file_path in ipairs(tb_plist) do
		if (GamePhysicsWorld:GetInstance():LoadPolygonBodyFromFile(str_file_path) ~= 1) then
			return 0
		end
	end
	return 1
end


function Physics:OnLoop(delta)
	if not PhysicsWorld then
		return
	end
	PhysicsWorld:Update(delta)
end

function Physics:SetGravity(gravity_x, gravity_y)
	if not PhysicsWorld then
		return 0
	end
	PhysicsWorld:SetGravity(gravity_x, gravity_y)
end

function Physics:OnMouseDown(x, y)
	if not PhysicsWorld then
		return 0
	end
	return PhysicsWorld:MouseDown(x, y)
end

function Physics:OnMouseMoved(x, y)
	if not PhysicsWorld then
		return 0
	end
	return PhysicsWorld:MouseMove(x, y)
end

function Physics:OnMouseEnded(x, y)
	if not PhysicsWorld then
		return 0
	end
	return PhysicsWorld:MouseUp(x, y)
end