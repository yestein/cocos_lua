--=======================================================================
-- File Name    : buff_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/6/16 11:45:21
-- Description  : buff manager
-- Modify       : 
--=======================================================================
if not BuffMgr then
	BuffMgr = {
		buff_template = {}
	}
end

function BuffMgr:Uninit()
	self.buff_config = nil
end

function BuffMgr:Init()
	self.buff_config = {}
end

function BuffMgr:NewBuffTemplate(template_id)
	assert(not self.buff_template[template_id])
	local template = Class:New(BuffBase, tostring(template_id))
	self.buff_template[template_id] = template
	return template
end

function BuffMgr:GetBuffTemplate(template_id)
	if not self.buff_template[template_id] then
		return
	end
	return self.buff_template[template_id]
end

function BuffMgr:LoadBuff(buff_id, buff_config)
	assert(not self.buff_config[buff_id])
	self.buff_config[buff_id] = buff_config
end

function BuffMgr:GetBuffConfig(buff_id)
	return self.buff_config[buff_id]
end

function BuffMgr:NewBuff(buff_id, template_id)
	local template = self:GetBuffTemplate(template_id)
	if not template then
		return
	end
	local buff = Class:New(template, tostring(buff_id))
	return buff
end