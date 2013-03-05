#pragma once

#include <OpenAL/al.h>
#include <GLM/glm.hpp>

namespace Ymir
{
    namespace Audio
    {
        class Listener
        {
        public:
            Listener();
            void setPosition(glm::vec3 new_pos);
            void setOrientation(glm::vec3 forward, glm::vec3 up);
        };
    };
};