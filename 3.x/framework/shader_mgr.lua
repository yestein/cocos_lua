--=======================================================================
-- File Name    : shader_mgr.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2015/1/6 11:27:13
-- Description  : description
-- Modify       :
--=======================================================================

if not ShaderMgr then
    ShaderMgr = {
        shader_list = {},
        GLProgramCache = nil,
    }
end

function ShaderMgr:Init()
    self.GLProgramCache = cc.GLProgramCache:getInstance()
    return 1
end

function ShaderMgr:AddShader(shader_name, vsh_file, fsh_file)
    local shader = cc.GLProgram:createWithFilenames(vsh_file, fsh_file)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION, cc.VERTEX_ATTRIB_POSITION)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR, cc.VERTEX_ATTRIB_COLOR)
    shader:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD, cc.VERTEX_ATTRIB_TEX_COORDS)

    shader:link()
    shader:updateUniforms()
    self.GLProgramCache:addGLProgram(shader, shader_name)
end

function ShaderMgr:GetShader(name)
    return self.GLProgramCache:getGLProgram(name)
end
