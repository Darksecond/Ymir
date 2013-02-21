#import <Foundation/Foundation.h>

#include <GLEW/glew.h>
#include <GLFW/GLFW.h>
#include <GLM/glm.hpp>

#include <iostream>
#include <vector>
#include <memory>
#include <sstream>

#include "Shader.h"
#include "Program.h"
#include "Bitmap.h"
#include "Texture.h"
#include "Camera.h"
#include "Mesh.h"
#include "Light.h"

#include "Scene.h"
#include "Entity.h"
#include "LightComponent.h"
#include "SpatialComponent.h"
#include "RenderEngine.h"
#include "CameraComponent.h"
#include "ModelComponent.h"

#include "ResourceManager.h"
#include "DirectoryManifest.h"

#include "RotateBehavior.h"
#include "FPSCameraBehavior.h"
#include "WSADMoveBehavior.h"

#include "ProgramResourceLoader.h"

using namespace Ymir;

const glm::vec2 SCREEN_SIZE(800, 600);

static std::string ResourceDirectory()
{
    NSString* path = [[NSBundle mainBundle] resourcePath];
    return std::string([path cStringUsingEncoding:NSUTF8StringEncoding]);
}

int frames = 0;
double t0 = 0.0;
void showFPS() {
    
    double t, fps;
    
    // Get current time
    t = glfwGetTime();  // Get number of seconds since glfwInit()
    // Calculate and display FPS (frames per second) in title bar.
    if( (t-t0) > 1.0 || frames == 0 )
    {
        fps = (double)frames / (t-t0);
        std::stringstream ss;
        ss << "Ymir | FPS: " << fps;
        glfwSetWindowTitle(ss.str().c_str());
        t0 = t;
        frames = 0;
    }
    frames ++;
}

int main(int argc, char* argv[])
{
    if(!glfwInit())
        throw std::runtime_error("glfwInit failed");
    
    glfwOpenWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MAJOR, 3);
    glfwOpenWindowHint(GLFW_OPENGL_VERSION_MINOR, 2);
    glfwOpenWindowHint(GLFW_WINDOW_NO_RESIZE, GL_TRUE);
    if(!glfwOpenWindow(SCREEN_SIZE.x, SCREEN_SIZE.y, 8, 8, 8, 8, 16, 0, GLFW_WINDOW))
        throw std::runtime_error("glfwOpenWindow failed. Can your hardware handle OpenGL 3.2?");
    
    // GLFW settings
    glfwDisable(GLFW_MOUSE_CURSOR);
    glfwSetMousePos(0, 0);
    glfwSetMouseWheel(0);
    //glfwSwapInterval(0); //uncomment for no v-sync

    glewExperimental = GL_TRUE; //stops glew crashing on OSX
    if(glewInit() != GLEW_OK)
        throw std::runtime_error("glewInit failed");
    glGetError(); //ignore any errors coming from glewInit, because they can be safely ignored.
    
    std::cout << "OpenGL version: " << glGetString(GL_VERSION) << std::endl;
    std::cout << "GLSL version: " << glGetString(GL_SHADING_LANGUAGE_VERSION) << std::endl;
    std::cout << "Vendor: " << glGetString(GL_VENDOR) << std::endl;
    std::cout << "Renderer: " << glGetString(GL_RENDERER) << std::endl;
    
    if(!GLEW_VERSION_3_2)
        throw std::runtime_error("OpenGL 3.2 API is not available.");
    
    
    //OpenGL settings
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);
    glEnable(GL_CULL_FACE);
    
    //resource management
    std::shared_ptr<DirectoryManifest> manifest = std::make_shared<DirectoryManifest>(ResourceDirectory());

    ResourceManager<Texture> textureManager;
    textureManager.addManifest(manifest);
    
    ResourceManager<Program, ProgramResourceLoader> programManager;
    programManager.addManifest(manifest);
    
    std::shared_ptr<Program> test = programManager.resource("test");
    std::shared_ptr<Program> test2 = programManager.resource("test2");
    std::shared_ptr<Texture> t = textureManager.resource("wooden-crate.jpg");
    std::shared_ptr<Mesh> m = std::make_shared<Mesh>(Mesh::cube());
    
    RenderEngine engine{*test, *test2};
    Scene scene{engine};
    
    Entity& camera = scene.assign();
    camera.assign<CameraComponent>(SCREEN_SIZE.x / SCREEN_SIZE.y);
    camera.assign<SpatialComponent>(glm::vec3{0.0, 0.0, 5.0});
    camera.assignBehavior(std::unique_ptr<Behavior>{new FPSCameraBehavior});
    camera.assignBehavior(std::unique_ptr<Behavior>{new WSADMoveBehavior});
    
    //light one (spot)
    Entity& light_one = scene.assign();
    light_one.assign<LightComponent>(glm::vec3{1.0, 1.0, 1.0}, glm::vec3{0.0, 0.15, 0.0});
    light_one.assign<SpatialComponent>(glm::vec3{7.0, 0.0, 0.0});
    
    //light two (directional)
    Entity& light_two = scene.assign();
    light_two.assign<SpatialComponent>(glm::vec3{0.0, 3.0, 0.0});
    auto light_two_lightc = light_two.assign<LightComponent>(glm::vec3{0.5, 0.5, 0.5});
    light_two_lightc->lightType = LightComponent::LightType::DIRECTIONAL;
    
    //model one (box)
    Entity& model_one = scene.assign();
    model_one.assign<SpatialComponent>(glm::vec3{0.0, 0.0, 0.0});
    model_one.assign<ModelComponent>(m, t);
    
    //model two (box)
    Entity& model_two = scene.assign();
    model_two.assign<SpatialComponent>(glm::vec3{5.0, 0.0, 0.0});
    model_two.assignBehavior(std::unique_ptr<Behavior>{new RotateBehavior});
    model_two.assign<ModelComponent>(m, t);
    
    double lastTime = glfwGetTime();
    while(glfwGetWindowParam(GLFW_OPENED))
    {
        double thisTime = glfwGetTime();
        double delta = thisTime - lastTime;
        lastTime = thisTime;
        
        showFPS(); //in titlebar
        
        //behaviors
        scene.update(delta);
        
        //engines
        engine.update(delta);
        
        GLenum error = glGetError();
        if(error != GL_NO_ERROR)
            std::cerr << "OpenGL Error " << error << ": " << (const char*)gluErrorString(error) << std::endl;
        
        //exit program if escape key is pressed
        if(glfwGetKey(GLFW_KEY_ESC))
            glfwCloseWindow();
    }
    
    glfwTerminate();
    
    return 0;
}