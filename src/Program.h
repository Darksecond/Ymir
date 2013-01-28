#pragma once

#include <GLEW/glew.h>
#include <memory>
#include <vector>

#include "Shader.h"

class Program
{
    GLuint _object;
public:
    Program(const std::vector<Shader>& shaders);
    Program(Program&& other);
    Program(const Program&) = delete;
    ~Program();
    
    Program& operator=(Program&& other);
    Program& operator=(const Program&) = delete;
    
    GLuint object() const;
    
    GLint attrib(const GLchar* attribName) const;
    GLint uniform(const GLchar* uniformName) const;
    
    inline void bind() const;
    inline void unbind() const;
};

class ProgramContext
{
    const Program& program;
public:
    ProgramContext(const Program& prog) : program(prog)
    {
        program.bind();
    }
    
    ~ProgramContext()
    {
        program.unbind();
    }
};

//INLINED METHODS
void Program::bind() const
{
    glUseProgram(_object);
}

void Program::unbind() const
{
    glUseProgram(0);
}