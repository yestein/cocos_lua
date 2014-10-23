--=======================================================================
-- File Name    : calculator.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2014/10/11 15:15:17
-- Description  : manage exp and level up
-- Modify       : 
--=======================================================================

if not Calculator then
	Calculator = {}
end

function Calculator:CalculateLevelExp(cur_level, cur_exp, add_exp, level_config)
	return self:ExchangeLevelExp(cur_level, cur_exp + add_exp, level_config)
end

function Calculator:ExchangeLevelExp(level, exp, level_config)
	local ret_level, ret_exp = level, exp
	local max_exp = level_config[ret_level]
	while max_exp and (ret_exp >= max_exp) do
		if level_config[ret_level + 1] then
			ret_level = ret_level + 1
			ret_exp = ret_exp - max_exp
			max_exp = level_config[ret_level]
		else
			if ret_exp > max_exp then
				ret_exp = max_exp
			end
			break
		end
	end
	return ret_level, ret_exp
end