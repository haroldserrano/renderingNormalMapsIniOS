//
//  Shader.vsh
//  openglesinc
//
//  Created by Harold Serrano on 2/9/15.
//  Copyright (c) 2015 www.roldie.com. All rights reserved.
//

//1. declare attributes
attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;
attribute vec4 tangentVector;

//2. declare varying type which will transfer the texture coordinates to the fragment shader
varying mediump vec2 vTexCoordinates;

//3. declare a uniform that contains the model-View-projection, model-View and normal matrix
uniform mat4 modelViewProjectionMatrix;
uniform mat4 modelViewMatrix;
uniform mat3 normalMatrix;

//4. declare varying variables that will provide the vertex position in model-view space
varying mediump vec4 positionInViewSpace;

//5. declare varying variables that will provide the normal position in model-view space
varying mediump vec3 normalInViewSpace;

//6. declare varying position of the light
varying vec4 lightPosition=vec4(2.0,-2.0,5.0,1.0);

void main()
{
    
//7. transform the vertex position to model-view space
positionInViewSpace=modelViewMatrix*position;

//8. transform the normal position to model-view space
normalInViewSpace=normalMatrix*normal;


//9. set tangent vector in view space
vec3 tangentVectorInViewSpace=normalize(normalMatrix*vec3(tangentVector));

//10. compute the binormal. See Listing 5
vec3 binormal=normalize(cross(normalInViewSpace,tangentVectorInViewSpace))*tangentVector.w;
    
//11. Transformation matrix from model-world-view space to tangent space. See Listing 4
mediump mat3 toTangentSpace=mat3(tangentVectorInViewSpace.x,binormal.x,normalInViewSpace.x,
                                tangentVectorInViewSpace.y,binormal.y,normalInViewSpace.y,
                                tangentVectorInViewSpace.z,binormal.z,normalInViewSpace.z);
    
//12. Transform the light position to model-view space
lightPosition=modelViewMatrix*lightPosition;
    
//13a. Transform the light to tangent space
lightPosition.xyz=normalize(toTangentSpace*(lightPosition.xyz));
    
//13.b Transform the vertex position to tangent space
positionInViewSpace.xyz=toTangentSpace*normalize(positionInViewSpace.xyz);
    
//14. recall that attributes can't be declared in fragment shaders. Nonetheless, we need the texture coordinates in the fragment shader. So we copy the information of "texCoord" to "vTexCoordinates", a varying type.

vTexCoordinates=texCoord;

//15. transform every position vertex by the model-view-projection matrix
gl_Position = modelViewProjectionMatrix * position;

}
