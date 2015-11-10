--=======================================================================
-- File Name    : lib_config_parser.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/10/15 14:42:58
-- Description  : description
-- Modify       :
--=======================================================================
if not ConfigParser then
    ConfigParser = {}
end

local FormulaBase = {}
function FormulaBase:_Init(raw_row_data, raw_line_no, raw_table_data)
    self.__AddBaseValue("line_no", raw_line_no)
    self.__AddBaseValue("row_data", raw_row_data)
    self.__AddBaseValue("table_data", raw_table_data)
end

function FormulaBase:_Uninit()
    self.line_no = nil
    self.row_data = nil
    self.table_data = nil
end

function FormulaBase:GetRunEnv()
    local raw_info = BattleMgr:GetLastBattleInfo()
    local info = {}
    local mt = {
        __index = function(tb, key)
            local v = rawget(raw_info, key)
            if v then
                return v
            end
            return 1
        end
    }
    setmetatable(info, mt)
    local ret_env = {
        level = (Player and Player.data) and Player:GetLevel() or 100,
        battle = info,
        _line = self.line_no,
        _row = self.row_data,
        _data = self.table_data,
        _random = grandom,
    }
    return ret_env
end

function FormulaBase:GetExpression()
    return self.__class_name
end

function FormulaBase:CalcValue()
    local formula_env = self:GetRunEnv()
    local f = load("return " .. self.__class_name, "formula", "t", formula_env)
    assert(f, self.__class_name)
    return f()
end

local function NewFormula(exp, raw_line_no, raw_row_data, raw_table_data)
    local formula = Class:New(FormulaBase, exp)
    formula:Init(raw_line_no, raw_row_data, raw_table_data)
    return formula
end

local IS_ENCODE = 1
local function Encode(str_content)
    -- return core.pack(string.pack(">s2", str_content))
    return str_content
end

local function Decode(str_content)
    -- return core.unpack(string.unpack(">s2", str_content))
    return str_content
end

local function ParseConfigLua(str_content)
    if not str_content or str_content == "" then
        return
    end
    return loadstring(str_content)()
end

local PARSE_TXT_FUNC_LIST = {
    str = function(v)
        if __CLIENT == 1 then
            return GBK2Utf8(v)
        else
            return v
        end
    end,

    lua = function(v)
        return Lib:Str2Val(v)
    end,

    num = function(v)
        return tonumber(v) or 0
    end,

    formula = function(v, row_data, raw_line_no, table_data)
        return NewFormula(v, row_data,  raw_line_no, table_data)
    end,

    static_formula = function(v, row_data, raw_line_no, table_data)
        return NewFormula(v, row_data,  raw_line_no, table_data):CalcValue()
    end,

    comment = function(v)
        return nil
    end,
}

local copy_parse_tb = Lib:CopyTB1(PARSE_TXT_FUNC_LIST)
for k, v in pairs(copy_parse_tb) do
    if k ~= "comment" then
        PARSE_TXT_FUNC_LIST["param_" .. k] = v
    end
end
copy_parse_tb = nil

local function _common_title(row_data, title_name, parse_func, v, ...)
    row_data[title_name] = parse_func(v, row_data, ...)
end

local function _param_title(row_data, title_name, parse_func, v, ...)
    if not row_data.__param then
        row_data.__param = {}
    end
    table.insert(row_data.__param, parse_func(v, row_data, ...))
end

local SAVE_TITLE_FUNC_LIST = {
    str = _common_title,
    lua = _common_title,
    num = _common_title,
    formula = _common_title,
    static_formula = _common_title,
}

local copy_save_tb = Lib:CopyTB1(SAVE_TITLE_FUNC_LIST)
for k, _ in pairs(copy_save_tb) do
    SAVE_TITLE_FUNC_LIST["param_"..k] = _param_title
end
copy_save_tb = nil

local function ParseConfigTable(str_content)

    if not str_content or str_content == "" then
        return
    end
    if IS_ENCODE == 1 then
        str_content = Decode(str_content)
    end
    local tb = {}
    local seperate_char
    if __SERVER == 1 then
        seperate_char = "\r\n"
    else
        if __platform == cc.PLATFORM_OS_WINDOWS then
            seperate_char = "\n"
        else
            seperate_char = "\r\n"
        end
    end
    local row_list = Lib:SplitToken(str_content, seperate_char)
    local row = -2
    local title_list
    local func_list = {}
    for _, line_content in ipairs(row_list) do
        if line_content == "" then
            break
        end
        row = row + 1
        local token_list = Lib:SplitToken(line_content, "\t")
        if row == -1 then
            title_list = token_list
        elseif row == 0 then
            for i, title in ipairs(title_list) do
                func_list[title] = token_list[i]
            end
        else
            tb[row] = {}
            for i, v in ipairs(token_list) do
                local title_name = title_list[i]
                local func_type = func_list[title_name]
                if func_type then

                    local parse_func = PARSE_TXT_FUNC_LIST[func_type]
                    local save_func = SAVE_TITLE_FUNC_LIST[func_type]
                    if not parse_func then
                        assert(false, "No Type Trans Func[%s]", tostring(func_type))
                        return
                    end
                    if save_func then
                        local len = #v
                        if v:sub(1, 1) == "\"" and v:sub(len, len) == "\"" then
                            v = v:sub(2, len - 1)
                        end

                        save_func(tb[row], title_name, parse_func, v, row, tb)
                    end
                else
                    tb[row][title_name] = v
                end
            end
        end
    end
    return tb
end

local CONFIG_PARSER = {
    ["lua"] = ParseConfigLua,
    ["table"] = ParseConfigTable,
}

function ConfigParser:GetParser(config_type)
    local func = CONFIG_PARSER[config_type]
    if not func then
        assert(false, "No Config[%s] Parser!!", config_type)
        return
    end
    return func
end

function ConfigParser:Parse(raw_str_content, config_type, ...)
    local func = self:GetParser(config_type)
    if not func then
        return
    end
    return func(raw_str_content, ...)
end

local function GeneratorConfigLua(tb)
    if not tb then
        return
    end
    return "return " .. Lib:Table2OrderStr(tb)
end

local function GeneratorConfigTable(tb)
    if not tb then
        return
    end
    local order_row_list = {}
    for k, v in pairs(tb) do
        table.insert(order_row_list, k)
    end
    table.sort(order_row_list, function(a, b) return a < b end)

    local str_content = ""
    str_content = "id"
    local value_1 = tb[order_row_list[1]]

    local order_col_list = {}
    for k, v in pairs(value_1) do
        table.insert(order_col_list, k)
    end

    table.sort(order_col_list, function(a, b) return a < b end)
    for _, k in ipairs(order_col_list) do
        str_content = str_content .. "\t" .. tostring(k)
    end
    str_content = str_content .. "\n"

    for _, id in ipairs(order_row_list) do
        str_content = str_content .. tostring(id)
        local value_list = tb[id]
        for _, value_name in ipairs(order_col_list) do
            local value = value_list[value_name]
            if type(value) == "table" then
                if value.CalcValue then
                    str_content = str_content .. "\t" .. value.__class_name
                else
                    str_content = str_content .. "\t" .. Lib:Table2Str(value)
                end
            else
                str_content = str_content .. "\t" .. tostring(value)
            end
        end
        str_content = str_content .. "\n"
    end
    str_content = str_content .. "\n"

    if IS_ENCODE == 1 then
        str_content = Encode(str_content)
    end
    return str_content
end

local CONFIG_GENERATOR = {
    ["lua"] = GeneratorConfigLua,
    ["table"] = GeneratorConfigTable,
}

function ConfigParser:GetGenerator(config_type)
    local func = CONFIG_GENERATOR[config_type]
    if not func then
        assert(false, "No Config[%s] Generator!!", config_type)
        return
    end
    return func
end

function ConfigParser:GenerateConfig(tb, config_type, ...)
    local func = self:GetGenerator(config_type)
    if not func then
        return
    end
    local str_content = func(tb, ...)
    return str_content
end

function TestGen()
    local tb = ModelConfig.model
    for _, data in pairs(tb) do
        if data.offset then
            data.offset_x = data.offset.x
            data.offset_y = data.offset.y
            data.offset = nil
        end
    end
    Lib:SaveFile("src/".. PROJECT_PATH .."/config/skelton_model_config.etb", ConfigParser:GenerateConfig(tb, "txt"))
end

function TestParse()
    local tb = Lib:LoadConfigFile("common/config/test/test_formula.txt", "table")
    print(#tb)
    for i = 1, #tb do
        local data = tb[i]

        print(data.id, type(data.id))
        print(data.test_num, type(data.test_num))
        print(data.test_exp, type(data.test_exp))
        print(data.test_exp:GetExpression())
        local exp_value = data.test_exp:CalcValue()
        print(exp_value, type(exp_value))
    end
end
