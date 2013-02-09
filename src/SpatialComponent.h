#pragma once

#include "Component.h"
#include "Program.h"

#include <GLM/glm.hpp>

namespace Ymir
{
    //TODO added parent reference component, so coordinates will be local
    class SpatialComponent : public Component<SpatialComponent>
    {
    public:
        glm::vec3 position;
        glm::quat direction;
        
        explicit SpatialComponent(glm::vec3 position);
        
        const glm::vec3 directionEuler() const;
        
        void setDirection(glm::quat& quat);
        void setDirection(glm::vec3& euler);
        
        glm::mat4 matrix() const;
    };
};