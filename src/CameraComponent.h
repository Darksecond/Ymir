#pragma once

#include "Component.h"

class CameraComponent : public iComponent<CameraComponent>
{
public:
    float _aspectratio;
    float _horizontalAngle;
    float _verticalAngle;
    
    CameraComponent(float aspectRatio);
};