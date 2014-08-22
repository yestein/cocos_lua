--=======================================================================
-- File Name    : movie.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/8/22 13:31:32
-- Description  : play movie by script
-- Modify       : 
--=======================================================================
if not Movie then
	Movie = {
		action_function = {}
	}
end

function Movie:Uninit()
	self.border_height = nil
	return 1
end

function Movie:Init(border_height)
	self.border_height = border_height
	if not self.script_config then
		self.script_config = {}
		print("Warnning!!!!!! No Move Script Config!!!!!!")
	end
	return 1
end

function Movie:SetBorderHeight(border_height)
	self.border_height = border_height
end

function Movie:GetBorderHeight()
	return self.border_height
end

function Movie:GetConfig(dialog_script)
	return self.script_config[dialog_script]
end

function Movie:Play(script_name, call_back)
	local config = self:GetConfig(script_name)
	if not config then
		assert(false)
		return
	end
	self.play_index = 0
	self.call_back = call_back
	self.script_name = script_name
	Event:FireEvent("MOVIE.START", self.script_name)
	self:_NextScript()
end

function Movie:Stop()
	local call_back = self.call_back
	Event:FireEvent("MOVIE.END", self.script_name)
	self.play_index  = nil
	self.script_name = nil
	self.call_back = nil
	if call_back then
		call_back()
	end
end

function Movie:_NextScript()
	local config = self:GetConfig(self.script_name)
	if not config then
		assert(false)
		return
	end
	self.play_index = self.play_index + 1
	local action_list = config[self.play_index]
	if not action_list then
		self:Stop()
		return
	end
	Event:FireEvent("MOVIE.PLAY", self.script_name, self.play_index)
	self:ExecuteActionList(action_list)
end

function Movie:ExecuteActionList(action_list)
	self.action_status = {}
	for template_name, template_action in pairs(action_list) do
		if self:ExecuteAction(template_name, template_action) == 1 then
			self.action_status[template_name] = 0
		end
	end
end

function Movie:IsAllActionDone()
	for _, is_done in pairs(self.action_status) do
		if is_done == 0 then
			return 0
		end
	end
	return 1
end

function Movie:ExecuteAction(template_name, template_action)
	local index = 0	
	local function OnActionDone()
		self.action_status[template_name] = 1
		print("call back")
		if self:IsAllActionDone() == 1 then
			self:_NextScript()
		end
	end
	local function DoAction()
		index = index + 1
		local action = template_action[index]
		if not action then
			OnActionDone()
			return
		end
		local action_name = action[1]
		local action_func = self.action_function[action_name]
		assert(action_func)
		if action_func[2] then
			return action_func[1](action_func[2], DoAction, template_name, unpack(action, 2))
		else
			return action_func[1](template_name, DoAction, unpack(action, 2))
		end
	end
	return DoAction()
end


function Movie:AddFunction(action_name, action_func, table)
	self.action_function[action_name] = {action_func, table}
end

function Movie:RemoveFunction(action_name)
	self.action_function[action_name] = nil
end