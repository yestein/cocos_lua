--=======================================================================
-- File Name    : class.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : date
-- Description  : simulate a table to a class in c++
--                     1. can use funciton declared in base class
--                     2. can make the call order of (Init | Uninit) like (instructor | destructor)
-- Modify       :
--=======================================================================

if not Class then
    Class = {}
end

-- Class.is_debug = 1
Class.depth = 0

local function AddInheritFunctionOrder(self, function_name)
    local function Inherit(self, ...)
        local execute_list = {}
        local base_class = self._tbBase
        local child_function_name = "_" .. function_name

        if Class.is_debug == 1 then
            log_print(string.format("%s>>%s %s Start", string.rep("  ", Class.depth), self:GetClassName(), function_name))
        end
        Class.depth = Class.depth + 1
        while base_class do
            local inherit_func = rawget(base_class, child_function_name)
            if inherit_func then
                execute_list[#execute_list + 1] = {inherit_func, rawget(base_class, "__class_name")}
            end
            base_class = base_class._tbBase
        end
        for i = #execute_list, 1, -1 do
            local func, name = unpack(execute_list[i])
            if Class.is_debug == 1 then
                log_print(string.format("%s%s %s..", string.rep("  ", Class.depth), tostring(name), function_name))
            end
            local success, result = Lib:SafeCall({func, self, ...})
            if not success then
                assert(false, "[%s] Order Execute [%s] Faield!", name, function_name)
                return 0
            end
        end
        if Class.is_debug == 1 then
            log_print(string.format("%s%s %s..", string.rep("  ", Class.depth), tostring(rawget(self, "__class_name")), function_name))
        end
        Class.depth = Class.depth - 1
        if Class.is_debug == 1 then
            log_print(string.format("%s!!%s %s End", string.rep("  ", Class.depth), self:GetClassName(), function_name))
        end
        local child_func = rawget(self, child_function_name)
        if not child_func then
            return 1
        end
        return child_func(self, ...)
    end
    self.__AddBaseValue(function_name, Inherit)
end

local function AddInheritFunctionDisorder(self, function_name)
    local function Inherit(self)
        local child_function_name = "_" .. function_name
        local child_func = rawget(self, child_function_name)
        if Class.is_debug == 1 then
            log_print(string.format("%s>>%s %s Start", string.rep("  ", Class.depth), self:GetClassName(), function_name))
        end
        Class.depth = Class.depth + 1
        local ret_code = 1
        if child_func then
            local result, ret = Lib:SafeCall({child_func, self})
            if not result then
                assert(false)
                ret_code = 0
            end
        end

        local execute_list = {}
        local base_class = self._tbBase
        while base_class do
            local inherit_func = rawget(base_class, child_function_name)
            if inherit_func then
                execute_list[#execute_list + 1] = {inherit_func, rawget(base_class, "__class_name")}
            end
            base_class = base_class._tbBase
        end
        for i = 1, #execute_list do
            local func, name = unpack(execute_list[i])
            if Class.is_debug == 1 then
                log_print(string.format("%s%s %s..", string.rep("  ", Class.depth), tostring(name), function_name))
            end
            local result, ret = Lib:SafeCall({func, self})
            if not result then
                assert(false, "[%s] Disorder Execute [%s] Faield!", name, function_name)
                ret_code = 0
            end
        end
        Class.depth = Class.depth - 1
        if Class.is_debug == 1 then
            log_print(string.format("%s!!%s %s End", string.rep("  ", Class.depth), self:GetClassName(), function_name))
        end
        return ret_code
    end
    self.__AddBaseValue(function_name, Inherit)
end

local function GetClassName(self)
    return self.__class_name
end

function Class:New(base_class, class_name)
    local new_class = {}
    local base_value_list = {
        __GetBaseValue = function()
            return base_value_list
        end,
        _tbBase = base_class,
        __AddInheritFunctionOrder = AddInheritFunctionOrder,
        __AddInheritFunctionDisorder = AddInheritFunctionDisorder,
        GetClassName = GetClassName,
    }
    base_value_list.__AddBaseValue = function(k, v)
        base_value_list[k] = v
    end,
    setmetatable(new_class,
        {
            __index = function(table, key)
                local v = base_value_list[key]
                if v then
                    return v
                end
                v = rawget(table, key)
                if v then
                    return v
                end
                if base_class then
                    return base_class[key]
                end
            end
        }
    )
    new_class:__AddInheritFunctionOrder("Init")
    new_class:__AddInheritFunctionDisorder("Uninit")

    new_class.__class_name = class_name --查看的时候还是需要看ClassName的
    return new_class
end

function Class:EnableDebug(is_debug)
    self.is_debug = is_debug
end
