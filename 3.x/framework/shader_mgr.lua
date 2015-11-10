--=======================================================================
-- File Name    : shader_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/1/6 11:27:13
-- Description  : description
-- Modify       :
--=======================================================================

if not ShaderMgr then
    ShaderMgr = {}
end

function ShaderMgr:Init()
    self.shader_list = {}
    return 1
end

function ShaderMgr:AddShader(shader_name, vsh_file, fsh_file)
    self.shader_list[shader_name] = {vsh_file, fsh_file}
end

function ShaderMgr:CreateShader(vsh_file, fsh_file)
    local shader = cc.GLProgram:createWithFilenames(vsh_file, fsh_file)
    return shader
end

function ShaderMgr:GetShader(shader_name)
    assert(self.shader_list[shader_name], shader_name)
    return ShaderMgr:CreateShader(unpack(self.shader_list[shader_name]))
end

local UNIFORM_FUNC_NAME = {
    float   = "setUniformFloat",
    int     = "setUniformInt",
    Mat4    = "setUniformMat4",
    texture = "setUniformTexture",
    vec2    = "setUniformVec2",
    vec3    = "setUniformVec3",
    vec4    = "setUniformVec4",
}

function ShaderMgr:AttachShader(cc_sprite, shader_name, uniform_list)
    local shader = ShaderMgr:GetShader(shader_name)
    if shader then
        if uniform_list then
            local gl_program_state = cc.GLProgramState:getOrCreateWithGLProgram(shader)
            for uniform_name, v in pairs(uniform_list) do
                local uniform_type, uniform_value = v[1], v[2]
                local fun_name = UNIFORM_FUNC_NAME[uniform_type]
                gl_program_state[fun_name](gl_program_state, uniform_name, uniform_value)
            end
        end
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

        shader:link()
        shader:updateUniforms()
        cc_sprite:setGLProgram(shader)
    end
end


function ShaderMgr:RestoreShader(cc_sprite)
    local state = cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor"))
    cc_sprite:setGLProgramState(state)
end

function ShaderMgr:AttachWigetShader(wiget_node, shader_name, uniform_list)
    local shader = ShaderMgr:GetShader(shader_name)
    if shader then
        if uniform_list then
            local gl_program_state = cc.GLProgramState:getOrCreateWithGLProgram(shader)
            for uniform_name, v in pairs(uniform_list) do
                local uniform_type, uniform_value = v[1], v[2]
                local fun_name = UNIFORM_FUNC_NAME[uniform_type]
                gl_program_state[fun_name](gl_program_state, uniform_name, uniform_value)
            end
        end
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
        shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

        shader:link()
        shader:updateUniforms()
        local cc_node = wiget_node:getVirtualRenderer()
        cc_node:setGLProgram(shader)
    end
end


function ShaderMgr:RestoreWigetShader(wiget_node)
    local state = cc.GLProgramState:getOrCreateWithGLProgram(cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP"))
    local cc_node = wiget_node:getVirtualRenderer()
    cc_node:setGLProgramState(state)
end