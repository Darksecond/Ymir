#include "LightComponent.h"

LightComponent::LightComponent(glm::vec3 color) : attenuation{1.0, 0.0, 0.0},
    diffuse{color}, specular{color}, ambient{color}, spot{1}
{
}

LightComponent::LightComponent(glm::vec3 color, glm::vec3 att) : attenuation{att},
    diffuse{color}, specular{color}, ambient{color}, spot{1}
{
}