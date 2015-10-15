--=======================================================================
-- File Name    : movie_node.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/8/18 14:33:01
-- Description  : description
-- Modify       :
--=======================================================================

local MovieNode = ComponentMgr:GetComponent("MOVIE")
if not MovieNode then
    MovieNode = ComponentMgr:CreateComponent("MOVIE")
end

function MovieNode:_Uninit()
    self.position = nil
    return 1
end

function MovieNode:_Init(position)
    self.position = position
    return 1
end

function MovieNode:MovieGoto(call_back, x, y, time)
    local owner = self:GetParent()
    local run_time = time
    if time > 0.1 then
        run_time = time - 0.1
    end
    local event_name = owner:GetClassName()..".MOVIE_MOVETO"
    Event:FireEvent(event_name, owner:GetId(), x, y, run_time)
    self:RegistRealTimer(math.ceil(time * GameMgr:GetFPS()), {call_back})
    if x > self.position.x then
        owner:TryCall("SetDirection", "right")
    elseif x < self.position.x then
        owner:TryCall("SetDirection", "left")
    end
    self.position.x = x
    self.position.y = y
end

function MovieNode:MovieSay(call_back, text, font_size, delay_time)
    local owner = self:GetParent()
    Event:FireEvent("SHOW_NORMAL_POPO", owner:GetId(), text, {font_size = font_size})
    self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {call_back})
end

function MovieNode:MovieEmoj(call_back, emoj_id, scale, delay_time)
    local owner = self:GetParent()
    Event:FireEvent("SHOW_EMOJ", owner:GetId(), emoj_id, {scale = scale})
    self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {call_back})
end

function MovieNode:MovieCloseEmoj(call_back, delay_time)
    local owner = self:GetParent()
    Event:FireEvent("HIDE_EMOJ", owner:GetId())
    self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {call_back})
end

function MovieNode:MoviePlayAnimation(call_back, animation_name, is_loop, delay_time)
    local owner = self:GetParent()
    local event_name = owner:GetClassName()..".PLAY_ANIMATION"
    Event:FireEvent(event_name, owner:GetId(), animation_name, is_loop)
    self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {call_back})
end

function MovieNode:MovieDelay(call_back, delay_time)
    self:RegistRealTimer(math.ceil(delay_time * GameMgr:GetFPS()), {call_back})
end
