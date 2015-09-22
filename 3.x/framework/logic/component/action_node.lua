--=======================================================================
-- File Name    : action_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/7/31 15:10:53
-- Description  : description
-- Modify       :
--=======================================================================

local ActionNode = ComponentMgr:GetComponent("ACTION")
if not ActionNode then
    ActionNode = ComponentMgr:CreateComponent("ACTION")
end

ActionNode.forbidden_rule = {}
ActionNode.allow_rule = {}

function ActionNode:_Uninit( ... )
    self.state = nil

    return 1
end

function ActionNode:_Init(state)
    if not state then
        state = Def.STATE_NORMAL
    end
    self.state = state
    return 1
end

function ActionNode:ClearRule()
    self.forbidden_rule = {}
    self.allow_rule = {}
end

function ActionNode:AddForbiddenRule(state, forbidden_state)
    if not self.forbidden_rule[state] then
        self.forbidden_rule[state] = {}
    end

    self.forbidden_rule[state][forbidden_state] = 1
end

function ActionNode:AddAllowRule(state, allow_state)
    if not self.allow_rule[state] then
        self.allow_rule[state] = {}
    end

    self.allow_rule[state][allow_state] = 1
end

function ActionNode:SetState(state, is_force)
    if not state then
        assert(false)
    end
    if not is_force then
        local allow_rule = self.allow_rule[state]
        if allow_rule and not allow_rule[self.state] then
            return 0
        end

        local forbidden_rule = self.forbidden_rule[self.state]
        if forbidden_rule and forbidden_rule[state] then
            return 0
        end
    end
    local old_state = self.state
    self.state = state

    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".CHANGE_STATE"
    Event:FireEvent(event_name, owner:GetId(), old_state, state)
    return 1
end

function ActionNode:GetState()
    return self.state
end
