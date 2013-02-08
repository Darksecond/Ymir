#pragma once

#include "Entity.h"
#include "ModelComponent.h"
#include "SpatialComponent.h"
#include "Program.h"

#include <GLM/glm.hpp>

class Model
{
public:
    std::shared_ptr<ModelComponent> model;
    std::shared_ptr<SpatialComponent> spatial;
    
    static std::unique_ptr<Model> fromEntity(const Entity& e);
    
    Model(std::shared_ptr<ModelComponent> m, std::shared_ptr<SpatialComponent> s) : model{m}, spatial{s} {}
    
    void attach(Program& p) const;
    
    bool operator==(const Model& other) const;
};