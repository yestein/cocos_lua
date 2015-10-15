--=======================================================================
-- File Name    : display_random.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/9/28 17:04:46
-- Description  : 随机性较差，仅供随机性要求并不是很高的表现端使用
--                避免使用lua的random函数影响逻辑的随机
-- Modify       :
--=======================================================================

if not DisplayRandom then
    DisplayRandom = {}
end

function DisplayRandom:Init(count)
    self.random_count = count
    self.random_content = {}
    for i = 1, count do
        self.random_content[i] = (i - 1) / count
    end
    for i = 1, count do
        local index = math.random(1, count)
        self.random_content[1], self.random_content[index] = self.random_content[index], self.random_content[1]
    end
    self.random_index = 1
end

function DisplayRandom:Get(...)
    local param_count = select('#', ...)
    local result = self.random_content[self.random_index]
    self.random_index = self.random_index + 1
    if self.random_index > self.random_count then
        self.random_index = self.random_index - self.random_count
    end
    if param_count == 0 then
        return result
    elseif param_count == 1 then
        local max = ...
        return math.floor(result * max)
    elseif param_count > 1 then
        local min, max = ...
        return min + math.floor(result * (max - min + 1))
    end
end
