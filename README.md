# GiraffeRender -- A Metal Render
A 3D scene render using MetalKit, Model I/O, SIMD and Swift5.0

![pbr](https://github.com/Howardw3/GiraffeRender/blob/master/Snapshot/pbr.png)
## Goal
### View
+ Scene ref :heavy_check_mark:
+ Playing action
+ Snapshot

### Scene
+ Tree
+ Point Of View :heavy_check_mark:
### Renderer
+ Draw Scene :heavy_check_mark:
+ Draw Node :heavy_check_mark:
+ Update projection matrix :heavy_check_mark:
+ Draw mesh :heavy_check_mark:
+ Basic texture :heavy_check_mark:
+ Triple buffering :heavy_check_mark:

### Lighting
+ Ambient :heavy_check_mark:
+ Omni :heavy_check_mark:
+ Spot :heavy_check_mark:
+ Directional :heavy_check_mark:
+ Light maps
  + Specular :heavy_check_mark:
  + Diffuse :heavy_check_mark:
  + Normal :heavy_check_mark:
  + Albedo :heavy_check_mark:
  + Roughness :heavy_check_mark:
+ Multiple lights
+ Advanced
  + Gamma correction :heavy_check_mark:
  + Shadows :heavy_check_mark:
  + HDR :heavy_check_mark:
  + SSAO
  + Deferred shading
  + Bloom
  + Parallax mapping
+ PBR :heavy_check_mark:
### Camera
+ Perspective :heavy_check_mark:
+ Orthographic
+ zFar :heavy_check_mark:
+ zNear :heavy_check_mark:
+ FOV :heavy_check_mark:

### Node
+ Translation :heavy_check_mark:
+ Rotation :heavy_check_mark:
  + EulerAngles :heavy_check_mark:
  + Quaternion
  + Rotation matrix
+ Scale  :heavy_check_mark:
+ Transform :heavy_check_mark:
+ World Transform
+ Pivot(vector) :heavy_check_mark:
+ Pivot(matrix)

### Geometry
+ Basic geo(MDLMesh) :heavy_check_mark:
  + Box
  + Sphere
  + Hemisphere
  + Cylinder
  + Capsule
  + Cone
  + Plane

## References
+ OpenGL Tutorial: https://learnopengl.com
+ Metal Shader: https://developer.apple.com/metal/Metal-Shading-Language-Specification.pdf
+ Metal Official: https://developer.apple.com/documentation/metal
+ Metal Examples: http://metalbyexample.com
