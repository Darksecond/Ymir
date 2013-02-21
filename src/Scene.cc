#include "Scene.h"

using namespace Ymir;

Scene::Scene(EngineManager& manager) : engines{manager}
{
}

Scene::~Scene()
{
    for(auto& entity : entities)
    {
        engines.unregisterEntity(*entity);
    }
}

Entity& Scene::assign(std::unique_ptr<Entity> entity)
{
    Entity& retval = *entity;
    entities.push_back(std::move(entity));
    return retval;
}

Entity& Scene::assign()
{
    std::unique_ptr<Entity> entity{new Entity{engines}};
    return assign(std::move(entity));
}

void Scene::update(double delta)
{
    for(auto& entity : entities)
    {
        entity->update(delta);
    }
}