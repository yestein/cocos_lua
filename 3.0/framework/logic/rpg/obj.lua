--=======================================================================
-- File Name    : obj.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/10 18:26:16
-- Description  : obj in rpg
-- Modify       : 
--=======================================================================

if not RpgObj then
	RpgObj = Class:New(ObjBase, "RPG_OBJ")
end


function RpgObj:_Uninit( ... )
	self.is_hero         = nil
	self.template_id     = nil
	self.camp            = nil
	self.property        = nil
	self.position        = nil
	self.attack_skill    = nil
	self.direction       = nil
	self.action_state    = nil
	self.target_id       = nil
	self.last_damager_id = nil
	return 1
end

function RpgObj:IsValid()
	if self.template_id then
		return 1
	end
	return 0
end

function RpgObj:_Init(id, is_hero, template_id, logic_x, logic_y, direction, camp)
	self.camp        = camp or Def.CAMP_WHITE
	self.is_hero     = is_hero
	self.template_id = template_id
	self.property    = {}

	
	local config = CharacterConfig:GetTemplate(template_id)
	if not config then
		assert(false)
		return
	end
	self.attack_speed = config.attack_speed or 1

	for key, value in pairs(config.property) do
		self.property[key] = value
	end
	local x, y = Map:Logic2Pixel(logic_x, logic_y)
	self.position = {x = x, y = y}
	if config.ai then
		local ai_node = Class:New(AINode)
		ai_node:Init()
		if config.ai then
			for i, ai_template_name in ipairs(config.ai) do
				local ai_template_list = AIConfig:GetTemplate(ai_template_name)
				assert(ai_template_list)
				for order, ai_name in pairs(ai_template_list) do
					ai_node:AddAI(ai_name, order)
				end
			end
		end
		if config.ai_param then
			ai_node:SetParam(config.ai_param)
		end
		if config.debug and config.debug.ai == 1 then
			ai_node:EnableDebug(1)
		end
		self:AddChild("ai", ai_node)
	end
	self.attack_skill = config.attack_skill

	if config.move_speed then
		local move_node = Class:New(MoveNode)
		move_node:Init(self:GetPosition(), config.move_speed)
		self:AddChild("move", move_node)
	end

	local cmd_node = Class:New(CmdNode)
	cmd_node:Init()
	self:AddChild("cmd", cmd_node)

	local skill_node = Class:New(SkillNode)	
	skill_node:Init()
	skill_node:SetAttackSkill(self.attack_skill)
	if config.extra_skill_list then
		for _, skill_config in ipairs(config.extra_skill_list) do
			skill_node:AddSkill(skill_config.skill_id, skill_config.level)
		end
	end
	self:AddChild("skill", skill_node)

	local buff_node = Class:New(BuffNode)
	buff_node:Init()
	self:AddChild("buff", buff_node)

	self.direction    = direction or config.resource_direction
	self.action_state = Def.STATE_NORMAL
	self.target_id    = 0
	self.last_damager_id = 0
	return 1
end

function RpgObj:IsHero()
	return self.is_hero
end

function RpgObj:GetCamp()
	return self.camp
end

function RpgObj:IsInState(judge_state)
	if self.action_state == judge_state then
		return 1
	end
	return 0
end

function RpgObj:GetTemplateId()
	return self.template_id
end

function RpgObj:GetActionState()
	return self.action_state
end

function RpgObj:SetActionState(action_state)
	if action_state == self.action_state then
		return
	end
	local old_state = self.action_state
	if old_state == "dead" then
		assert(false)
	end
	self.action_state = action_state
	local event_name = self:GetClassName()..".CHANGE_STATE"
	Event:FireEvent(event_name, self:GetId(), old_state, action_state)
end

function RpgObj:GetAttackSkillId()
	return self.attack_skill
end

function RpgObj:CanAttack(target_id)
	local target = CharacterPool:GetById(target_id)
	if not target then
		return 0
	end
	local skill_id = self:GetAttackSkillId()
	return self:TryCall("CanCastSkill", skill_id, {target_id})
end

function RpgObj:IsTargetValid(target_id)
	if not target_id then
		return 0
	end
	local target = CharacterPool:GetById(target_id)
	if not target then
		return 0
	end
	local skill_id = self:GetAttackSkillId()
	return self:TryCall("IsSkillTargetValid", skill_id, target)
end

function RpgObj:Attack(target_id)
	if self:CanAttack(target_id) ~= 1 then
		return
	end
	local target = CharacterPool:GetById(target_id)
	assert(target)
	local self_x, _ = self:GetLogicXY()
	local target_x, _ = target:GetLogicXY()
	if target_x > self_x then
		self:SetDirection("right")
	elseif target_x < self_x then
		self:SetDirection("left")
	end
	local skill_id = self:GetAttackSkillId()
	self:SetTargetId(target_id)
	return self:TryCall("CastSkill", skill_id)
end

function RpgObj:TryAttack(target_id)
	if self:IsInState(Def.STATE_DEAD) == 1 then
		return
	end
	if self:IsTargetValid(target_id) ~= 1 then
		return
	end
	if self:CanAttack(target_id) == 1 then
		self:TryCall("Stop")
		return self:Attack(target_id)
	end

	local target = CharacterPool:GetById(target_id)
	assert(target)

	local position = target:GetPosition()
	self:InsertCommand({"GoTo", position.x, position.y})
	self:InsertCommand({"TryAttack", target_id}, 2)
end

function RpgObj:BeHit()
	if self:IsInState(Def.STATE_DEAD) == 1 then
		return
	end
	self:TryCall("Stop")
	self:SetActionState(Def.STATE_NORMAL)
	local event_name = self:GetClassName()..".BEHIT"
	Event:FireEvent(event_name, self:GetId())
end

function RpgObj:SetTargetId(id)
	self.target_id = id
end

function RpgObj:GetTargetId()
	return self.target_id
end

function RpgObj:GetMoveSpeed()
	return self:GetChild("move"):GetMoveSpeed()
end

function RpgObj:SetAttackSpeed(attack_speed)
	self.attack_speed = attack_speed
	local event_name = self:GetClassName()..".SET_ATTACK_SPEED"
	Event:FireEvent(event_name, self:GetId(), attack_speed)
end

function RpgObj:GetAttackSpeed()
	return self.attack_speed
end

function RpgObj:InsertCommand(command, delay_frame)
	if self:IsInState(Def.STATE_DEAD) == 1 then
		return
	end
	local cmd_node = self:GetChild("cmd")
	assert(cmd_node)
	cmd_node:InsertCommand(command, delay_frame)
end

function RpgObj:SetPosition(x, y)
	self.position.x = x
	self.position.y = y
end

function RpgObj:StrikeMove(logic_x, logic_y)
	local x, y = Map:Logic2Pixel(logic_x, logic_y)
	local event_name = self:GetClassName()..".STRIKE_MOVE"
	Event:FireEvent(event_name, self:GetId(), x, y)
	self:SetPosition(x, y)	
end

function RpgObj:GetPosition()
	return self.position
end
function RpgObj:GetLogicXY()
	return Map:Pixel2Logic(self.position.x, self.position.y)
end

function RpgObj:SetDirection(direction)
	if self.direction ~= direction then
		self.direction = direction
		local event_name = self:GetClassName()..".CHANGE_DIRECTION"
		Event:FireEvent(event_name, self:GetId(), direction)
	end
end

function RpgObj:GetDirection()
	return self.direction
end

function RpgObj:SetProperty(key, value)
	self.property[key] = value
end

function RpgObj:GetProperty(key)
	return self.property[key]
end

function RpgObj:GetLifePercentage()
	local life = self:GetProperty("life")
	local max_life = self:GetProperty("max_life")
	local percentage = life * 100 / max_life
	return percentage
end

function RpgObj:ChangeProperty(key, change_value)
	local old_value = self:GetProperty(key)
	local new_value = old_value + change_value
	if new_value < 0 then
		new_value = 0
	end

	local max_key = "max_"..key
	local max_value = self:GetProperty(max_key)
	
	if max_value then
		if new_value > max_value then
			new_value = max_value
		end
	end
	if old_value == new_value then
		return
	end
	self:SetProperty(key, new_value)
	local event_name = self:GetClassName()..".CHANGE_PROPERTY"
	Event:FireEvent(event_name, self:GetId(), key, old_value, new_value)
	if key == "life" and new_value <= 0 then
		self:Dead()
	end
end

function RpgObj:Dead()
	self:TryCall("Stop")
	self:SetActionState(Def.STATE_DEAD)
	local buff_node = self:GetChild("buff")
	if buff_node then
		buff_node:ReceiveMessage("OnOwnerDead")
	end
	if self:IsHero() ~= 1 then
		self:Remove()
	end
end

function RpgObj:Remove()
	if self:GetId() == Controller:GetSelectTargetId() then
		Controller:SelectTarget(nil)
	end
	CharacterPool:Remove(self:GetId())
end

local around_pos = {
	right = {{-1, 0}, {-1, 1}, {-1, -1}, {0, 1}, {0, -1}, {1, 1}, {1, -1}, {1, 0}},
	left = {{1, 0}, {1, 1}, {1, -1}, {0, 1}, {0, -1}, {-1, 1}, {-1, -1}, {-1, 0}},
}
function RpgObj:GetNearByPos(logic_x, logic_y)
	local max_x, max_y = Map:GetSize()
	if logic_x > max_x then
		logic_x = max_x
	elseif logic_x < 1 then
		logic_x = 1
	end
	if logic_y > max_y then
		logic_y = max_y
	elseif logic_y < 1 then
		logic_y = 1
	end

	local index = 0
	local offset_list = nil
	local self_x, _ = self:GetLogicXY()
	if logic_x > self_x then
		offset_list = around_pos["right"]
	else
		offset_list = around_pos["left"]
	end
	local function GetAroundPos()
		index = index + 1
		if index > #offset_list then
			return
		end
		return unpack(offset_list[index])
	end
	local new_logic_x, new_logic_y = logic_x, logic_y
	local count = Map:GetCellCount(new_logic_x, new_logic_y)
	while count and count ~= 0 do
		local offset_x, offset_y = GetAroundPos()
		new_logic_x = logic_x + offset_x
		new_logic_y = logic_y + offset_y
		if not new_logic_x or not new_logic_y then
			count = nil
		else
			count = Map:GetCellCount(new_logic_x, new_logic_y)
		end
	end

	return new_logic_x, new_logic_y
end

function RpgObj:TryGoTo(logic_x, logic_y)
	logic_x, logic_y = self:GetNearByPos(logic_x, logic_y)
	if logic_x and logic_y then
		local x, y = Map:Logic2Pixel(logic_x, logic_y)
		self:GetChild("move"):GoTo(x, y)
	end
end

function RpgObj:SetLastDamager(id)
	self.last_damager_id = id
end

function RpgObj:GetLastDamager()
	return self.last_damager_id
end

function RpgObj:Say(text)
	Event:FireEvent("SHOW_NOMRAL_POPO", self:GetId(), text)
end

function RpgObj:IsPositionInRange(target_x, target_y, range_x, range_y)
	if not range_y then
		range_y = range_x
	end
	local x, y = self:GetLogicXY()
	local direction = self:GetDirection()
	local min_x = nil
	local max_x = nil
	if direction == "left" then
		min_x = x - range_x
		max_x = x
	else
		min_x = x
		max_x = x + range_x
	end
	local min_y = y - range_y
	local max_y = y + range_y


	if target_x < min_x or target_x > max_x or target_y < min_y or target_y > max_y then
		return 0
	end
	return 1
end

function RpgObj:IsPositionInAround(target_x, target_y, range_x, range_y)
	if not range_y then
		range_y = range_x
	end
	local x, y = self:GetLogicXY()
	local min_x = x - range_x
	local max_x = x + range_x
	local min_y = y - range_y
	local max_y = y + range_y


	if target_x < min_x or target_x > max_x or target_y < min_y or target_y > max_y then
		return 0
	end
	return 1
end