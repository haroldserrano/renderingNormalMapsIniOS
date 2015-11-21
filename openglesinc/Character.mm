//
//  Character.mm
//  OpenGL_Template_CPLUSPLUS
//
//  Created by Harold Serrano on 7/25/14.
//  Copyright (c) 2015 www.haroldserrano.com. All rights reserved.
//

#include "Character.h"
#include "lodepng.h"
#include <vector>
#include "SmallHouse.h"

static GLubyte shaderText[MAX_SHADER_LENGTH];

Character::Character(float uScreenWidth,float uScreenHeight){
    
    screenWidth=uScreenWidth;
    screenHeight=uScreenHeight;
}

void Character::setupOpenGL(){
    
    
    //load the shaders, compile them and link them
    
    loadShaders("Shader.vsh", "Shader.fsh");
    
    glEnable(GL_DEPTH_TEST);
    
    //1. Generate a Vertex Array Object
    
    glGenVertexArraysOES(1,&vertexArrayObject);
    
    //2. Bind the Vertex Array Object
    
    glBindVertexArrayOES(vertexArrayObject);
    
    //3. Generate a Vertex Buffer Object
    
    glGenBuffers(1, &vertexBufferObject);
    
    //4. Bind the Vertex Buffer Object
    
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferObject);
    
    //5. Dump the data into the Buffer
    /* Read "Loading data into OpenGL Buffers" if not familiar with loading data
    using glBufferSubData.
    http://www.www.haroldserrano.com/blog/loading-vertex-normal-and-uv-data-onto-opengl-buffers
    */
    
    glBufferData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv)+sizeof(smallHouse_tangent), NULL, GL_STATIC_DRAW);
    
    //5a. Load vertex data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, 0, sizeof(smallHouse_vertices), smallHouse_vertices);
    
    //5b. Load normal data with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices), sizeof(smallHouse_normal), smallHouse_normal);
    
    //5c. Load UV coordinates with glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices)+sizeof(smallHouse_normal), sizeof(smallHouse_uv), smallHouse_uv);
    
    //5d. Load Tangent data into glBufferSubData
    glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv), sizeof(smallHouse_tangent), smallHouse_tangent);
    
    //6. Get the location of the shader attribute called "position"
    
    positionLocation=glGetAttribLocation(programObject, "position");
    
    //7. Get the location of the shader attribute called "normal"
    
    normalLocation=glGetAttribLocation(programObject, "normal");
    
    //8. Get the location of the shader attribute called "texCoords"
    
    uvLocation=glGetAttribLocation(programObject, "texCoord");
    
    tangentLocation=glGetAttribLocation(programObject, "tangentVector");
    
    //8. Get Location of uniforms
    modelViewProjectionUniformLocation = glGetUniformLocation(programObject,"modelViewProjectionMatrix");
    
    modelViewUniformLocation=glGetUniformLocation(programObject, "modelViewMatrix");
    
    normalMatrixUniformLocation = glGetUniformLocation(programObject,"normalMatrix");
    
    //9. Enable both attribute locations
    
    //9a. Enable the position attribute
    glEnableVertexAttribArray(positionLocation);

    //9b. Enable the normal attribute
    glEnableVertexAttribArray(normalLocation);
    
    //9c. Enable the UV attribute
    glEnableVertexAttribArray(uvLocation);
    
    glEnableVertexAttribArray(tangentLocation);
    
    //10. Link the buffer data to the shader attribute locations
    
    //10a. Link the buffer data to the shader's position location
    glVertexAttribPointer(positionLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid *) 0);

    //10b. Link the buffer data to the shader's normal location
    glVertexAttribPointer(normalLocation, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)sizeof(smallHouse_vertices));
    
    //10c. Link the buffer data to the shader's UV location
    glVertexAttribPointer(uvLocation, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)(sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)));

    //10d. Link the buffer data to the shader's tangent location
    glVertexAttribPointer(tangentLocation, 4, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)(sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv)));
    
    /*Since we are going to start the rendering process by using glDrawElements
     We are going to create a buffer for the indices. Read "Starting the rendering process in OpenGL"
     if not familiar. http://www.www.haroldserrano.com/blog/starting-the-primitive-rendering-process-in-opengl */
    
    //11. Create a new buffer for the indices
    GLuint elementBuffer;
    glGenBuffers(1, &elementBuffer);
    
    //12. Bind the new buffer to binding point GL_ELEMENT_ARRAY_BUFFER
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, elementBuffer);
    
    //13. Load the buffer with the indices found in smallHouse_index array
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(smallHouse_index), smallHouse_index, GL_STATIC_DRAW);
    
    
    //14. Activate GL_TEXTURE0
    glActiveTexture(GL_TEXTURE0);
    
    //15.a Generate a texture buffer
    glGenTextures(1, &textureID[0]);
    
    //16 Bind texture0
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //17. Decode image into its raw image data. "smallHouse_diffuse.png" is our formatted image.
    if(convertImageToRawImage("small_house_diffuse.png")){
    
    //if decompression was successful, set the texture parameters
        
    //17a. set the texture wrapping parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    //17b. set the texture magnification/minification parameters
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //17c. load the image data into the current bound texture buffer
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
    
    }
    
    //18. Get the location of the Uniform Sampler2D
    UVMapUniformLocation=glGetUniformLocation(programObject, "DiffuseTextureMap");
    
    
    //LOAD NORMAL MAP TEXTURE
    
    //19. Activate GL_TEXTURE1
    glActiveTexture(GL_TEXTURE1);
    
    //20 Generate a texture buffer
    glGenTextures(1, &textureID[1]);
    
    //21 Bind texture1
    glBindTexture(GL_TEXTURE_2D, textureID[1]);
    
    //22. Decode image into its raw image data. "small_house_normal.png" is our formatted image.
    if(convertImageToRawImage("small_house_normal.png")){
        
        //if decompression was successful, set the texture parameters
        
        //22a. set the texture wrapping parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        //22b. set the texture magnification/minification parameters
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        //22c. load the image data into the current bound texture buffer
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0,
                     GL_RGBA, GL_UNSIGNED_BYTE, &image[0]);
        
    }
    
    //23. Get the location of the Uniform Sampler2D
    NormalMapUniformLocation=glGetUniformLocation(programObject, "NormalTextureMap");
    
    
    //24. Unbind the VAO
    glBindVertexArrayOES(0);
    
    //Sets the transformation
    setTransformation();
    
}

void Character::update(float dt){
    
    //1. Rotate the model space by "dt" degrees about the vertical axis
    modelSpace=GLKMatrix4Rotate(modelSpace, dt, 0.0f, 0.0f, 1.0f);
    
    
    //2. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    
    //3. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //4. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    //5. extract the 3x3 normal matrix from the model-world-view space for shading(light) purposes
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelWorldViewSpace), NULL);
    
    
    //6. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    //7. Assign the normalMatrix data to the uniform location:normalMatrixUniformLocation
    glUniformMatrix3fv(normalMatrixUniformLocation, 1, 0, normalMatrix.m);
    
    
    //glUniformMatrix4fv(modelViewUniformLocation, 1, 0, modelWorldViewSpace.m);
}

void Character::draw(){
    
    //1. Set the shader program
    glUseProgram(programObject);
    
    //2. Bind the VAO
    glBindVertexArrayOES(vertexArrayObject);
   
    //3. Activate the texture unit
    glActiveTexture(GL_TEXTURE0);
    
    //4 Bind the texture object
    glBindTexture(GL_TEXTURE_2D, textureID[0]);
    
    //5. Specify the value of the UV Map uniform
    glUniform1i(UVMapUniformLocation, 0);
    
    
    //3. Activate the texture unit
    glActiveTexture(GL_TEXTURE1);
    
    //4 Bind the texture object
    glBindTexture(GL_TEXTURE_2D, textureID[1]);
    
    //5. Specify the value of the UV Map uniform
    glUniform1i(NormalMapUniformLocation, 1);
    
    //6. Start the rendering process
    glDrawElements(GL_TRIANGLES, sizeof(smallHouse_index)/4, GL_UNSIGNED_INT,(void*)0);
    
    //7. Disable the VAO
    glBindVertexArrayOES(0);
    
}



void Character::setTransformation(){
    
    //1. Set up the model space
    modelSpace=GLKMatrix4Identity;
    
    //Since we are importing the model from Blender, we need to change the axis of the model
    //else the model will not show properly. x-axis is left-right, y-axis is coming out the screen, z-axis is up and
    //down
    
    GLKMatrix4 blenderSpace=GLKMatrix4MakeAndTranspose(1,0,0,0,
                                                        0,0,1,0,
                                                        0,-1,0,0,
                                                        0,0,0,1);
    
    //2. Transform the model space by Blender Space
    modelSpace=GLKMatrix4Multiply(blenderSpace, modelSpace);
    
    
    //3. translate the model down
    modelSpace=GLKMatrix4Translate(modelSpace, 0.0, 0.0, -2.0);
    
    //4. Set up the world space
    worldSpace=GLKMatrix4Identity;
    
    //5. Transform the model space to the world space
    modelWorldSpace=GLKMatrix4Multiply(worldSpace,modelSpace);
    
    //6. Set up the view space. We are translating the view space 0 unit down and 7 units out of the screen.
    cameraViewSpace = GLKMatrix4MakeTranslation(0.0f, 0.0f, -10.0f);
    
    cameraViewSpace=GLKMatrix4Rotate(cameraViewSpace, GLKMathDegreesToRadians(-60.0), 0.0, 1.0, 0.0);
    
    //7. Transform the model-World Space by the View space
    modelWorldViewSpace = GLKMatrix4Multiply(cameraViewSpace, modelWorldSpace);
    
    
    //8. set the Projection-Perspective space with a 45 degree field of view and an aspect ratio
    //of width/heigh. The near a far clipping planes are set to 0.1 and 100.0 respectively
    projectionSpace = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0f), fabsf(screenWidth/screenHeight), 0.1f, 100.0f);
    
    
    //9. Transform the model-world-view space to the projection space
    modelWorldViewProjectionSpace = GLKMatrix4Multiply(projectionSpace, modelWorldViewSpace);
    
    //10. extract the 3x3 normal matrix from the model-world-view space for shading(light) purposes
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelWorldViewSpace), NULL);

    
    //11. Assign the model-world-view-projection matrix data to the uniform location:modelviewProjectionUniformLocation
    glUniformMatrix4fv(modelViewProjectionUniformLocation, 1, 0, modelWorldViewProjectionSpace.m);
    
    //12. Assign the normalMatrix data to the uniform location:normalMatrixUniformLocation
    glUniformMatrix3fv(normalMatrixUniformLocation, 1, 0, normalMatrix.m);
    
    //13. Assign the model-view matrix data to the uniform location:modelViewMatrixUniform
    glUniformMatrix4fv(modelViewUniformLocation, 1, 0, modelWorldViewSpace.m);
    
    
}


void Character::calculateTangentVectors(){
    
    //create vectors of GLKVectorX data type
    vector<GLKVector3> vertex;
    vector<GLKVector3> normal;
    vector<GLKVector2> uvCoord;
    vector<float> indexes;
    
    //Craeate arrays of GLKVectorx data type
    GLKVector3 tang[2*VERTEXCOUNT];
    GLKVector3 bitang[2*VERTEXCOUNT];
    GLKVector4 tangentVector[VERTEXCOUNT];
    
    
    
    //1. load all vertices into a vector of GLKVector3 data type
    for (int i=0; i<=VERTEXCOUNT-1;) {
        
        GLKVector3 vertexValue=GLKVector3Make(smallHouse_vertices[i], smallHouse_vertices[i+1], smallHouse_vertices[i+2]);
        
        vertex.push_back(vertexValue);
        
        i=i+3;
    }
    
    
    //2. load all normal into a vector of GLKVector3 data type
    for (int i=0; i<=VERTEXCOUNT-1;) {
        
        GLKVector3 normalValue=GLKVector3Make(smallHouse_normal[i], smallHouse_normal[i+1], smallHouse_normal[i+2]);
        
        normal.push_back(normalValue);
        
        i=i+3;
    }
    

    //3. load all UV into a vector of GLKVector2 data type
    for (int i=0; i<=UVCOUNT-1;) {
        
        GLKVector2 uvValue=GLKVector2Make(smallHouse_uv[i], smallHouse_uv[i+1]);
        
        uvCoord.push_back(uvValue);
        
        i=i+2;
    }
    
    //4. load all indexes into a vector of float type
    for (int i=0; i<=TRIANGLECOUNT-1; i++) {
        indexes.push_back(smallHouse_index[i]);
    }
    
    
    for (int i=0; i<=TRIANGLECOUNT-1;) {
        
        int i1=indexes.at(i);
        int i2=indexes.at(i+1);
        int i3=indexes.at(i+2);
        
        //5. Get the vertex position of a triangle
        GLKVector3 P0=vertex.at(i1);
        GLKVector3 P1=vertex.at(i2);
        GLKVector3 P2=vertex.at(i3);
        
        //6. Get the UV coordinates of a triangle
        GLKVector2 w0=uvCoord.at(i1);
        GLKVector2 w1=uvCoord.at(i2);
        GLKVector2 w2=uvCoord.at(i3);
        
        //7. Assemble Triangles Q1 and Q2
        GLKVector3 Q1=GLKVector3Make(P1.x-P0.x, P1.y-P0.y, P1.z-P0.z);
        GLKVector3 Q2=GLKVector3Make(P2.x-P0.x, P2.y-P0.y, P2.z-P0.z);
        
        //8. UV Coordinates of triangle Q1 and Q2
        GLKVector2 s=GLKVector2Make(w1.x-w0.x, w2.x-w0.x);
        GLKVector2 t=GLKVector2Make(w1.y-w0.y, w2.y-w0.y);
        
        
        //9. Calculate the coefficient in listing 2.
        float r=1.0f/(s.x*t.y-s.y*t.x);
        
        //10. Calculate the tangent and bitangent vectors as in listing 2.
        GLKVector3 tangentVector=GLKVector3Make((t.y*Q1.x-t.x*Q2.x)*r, (t.y*Q1.y-t.x*Q2.y)*r, (t.y*Q1.z-t.x*Q2.z)*r);
        GLKVector3 bitangentVector=GLKVector3Make((s.x*Q2.x-s.y*Q1.x)*r, (s.x*Q2.y-s.y*Q1.y)*r, (s.x*Q2.z-s.y*Q1.z)*r);
        
        
        //11. Average the tangent and bitangent vectors
        tang[i1]=GLKVector3Add(tang[i1], tangentVector);
        tang[i2]=GLKVector3Add(tang[i2], tangentVector);
        tang[i3]=GLKVector3Add(tang[i3], tangentVector);
        
        bitang[i1]=GLKVector3Add(bitang[i1], bitangentVector);
        bitang[i2]=GLKVector3Add(bitang[i2], bitangentVector);
        bitang[i3]=GLKVector3Add(bitang[i3], bitangentVector);
        
        i=i+3;
    }
    
    
    for (int a=0; a<=TRIANGLECOUNT-1;a++) {
        
        GLKVector3 n=normal.at(a);
        GLKVector3 t=tang[a];
        
        //12. Orthogonalize the tangent vector with the Gram-Schmidt algorithm. See listing 5
        GLKVector3 tangentTransposeVector=GLKVector3MultiplyScalar(n, GLKVector3DotProduct(n, t));
        tangentTransposeVector=GLKVector3Subtract(t, tangentTransposeVector);
        tangentTransposeVector=GLKVector3Normalize(tangentTransposeVector);
        
        //13. Calculate handedness of the tangent vector
        float handedness=(GLKVector3DotProduct(GLKVector3CrossProduct(n, t), bitang[a])<0.0f)?-1.0f:1.0f;
        
        
        tangentVector[a]=GLKVector4Make(tangentTransposeVector.x, tangentTransposeVector.y, tangentTransposeVector.z, 0.0);
        
        tangentVector[a].w=handedness;
        
    }
    
    int n=0;
    
    for (int i=0; i<=TRIANGLECOUNT-1; i++) {
        
        //14. Load the tangent data into the tangentVertices array to then be loaded into an OpenGL buffer.
        smallHouse_tangent[i+3*n]=tangentVector[i].x;
        smallHouse_tangent[i+1+3*n]=tangentVector[i].y;
        smallHouse_tangent[i+2+3*n]=tangentVector[i].z;
        smallHouse_tangent[i+3+3*n]=tangentVector[i].w;
    
        n++;
    }
    
}

bool Character::convertImageToRawImage(const char *uTexture){
    
    bool success=false;
    
    //clear the array
    image.clear();
    
    //The method decode() is the method rensponsible for decompressing the formated image.
    //The result is stored in "image".
    
    unsigned error = lodepng::decode(image, imageWidth, imageHeight,uTexture);
    
    //if there's an error, display it
    if(error){
    
        cout << "Couldn't decode the image. decoder error " << error << ": " << lodepng_error_text(error) << std::endl;
        
    }else{
        
        //Flip and invert the image
        unsigned char* imagePtr=&image[0];
        
        int halfTheHeightInPixels=imageHeight/2;
        int heightInPixels=imageHeight;
        
        
        //Assume RGBA for 4 components per pixel
        int numColorComponents=4;
        
        //Assuming each color component is an unsigned char
        int widthInChars=imageWidth*numColorComponents;
        
        unsigned char *top=NULL;
        unsigned char *bottom=NULL;
        unsigned char temp=0;
        
        for( int h = 0; h < halfTheHeightInPixels; ++h )
        {
            top = imagePtr + h * widthInChars;
            bottom = imagePtr + (heightInPixels - h - 1) * widthInChars;
            
            for( int w = 0; w < widthInChars; ++w )
            {
                // Swap the chars around.
                temp = *top;
                *top = *bottom;
                *bottom = temp;
                
                ++top;
                ++bottom;
            }
        }
        
        success=true;
    }
    
    return success;
}



void Character::loadShaders(const char* uVertexShaderProgram, const char* uFragmentShaderProgram){
    
    // Temporary Shader objects
    GLuint VertexShader;
    GLuint FragmentShader;
    
    //1. Create shader objects
    VertexShader = glCreateShader(GL_VERTEX_SHADER);
    FragmentShader = glCreateShader(GL_FRAGMENT_SHADER);
	
    
    //2. Load both vertex & fragment shader files
    
    //2a. Usually you want to check the return value of the loadShaderFile function, if
    //it returns true, then the shaders were found, else there was an error.
    
    
    if(loadShaderFile(uVertexShaderProgram, VertexShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uVertexShaderProgram);
        
    }else{
        
        fprintf(stderr,"Vertex Shader was loaded successfully\n");
        
    }
    
    if(loadShaderFile(uFragmentShaderProgram, FragmentShader)==false){
        
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        fprintf(stderr, "The shader at %s could not be found.\n", uFragmentShaderProgram);
    }else{
        
        fprintf(stderr,"Fragment Shader was loaded successfully\n");
        
    }
    
    //3. Compile both shader objects
    glCompileShader(VertexShader);
    glCompileShader(FragmentShader);
    
    //3a. Check for errors in the compilation
    GLint testVal;
    
    //3b. Check if vertex shader object compiled successfully
    glGetShaderiv(VertexShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(VertexShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uVertexShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Vertex Shader compiled successfully\n");
    }
    
    //3c. Check if fragment shader object compiled successfully
    glGetShaderiv(FragmentShader, GL_COMPILE_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetShaderInfoLog(FragmentShader, 1024, NULL, infoLog);
        fprintf(stderr, "The shader at %s failed to compile with the following error:\n%s\n", uFragmentShaderProgram, infoLog);
        glDeleteShader(VertexShader);
        glDeleteShader(FragmentShader);
        
    }else{
        fprintf(stderr,"Fragment Shader compiled successfully\n");
    }

    
    //4. Create a shader program object
    programObject = glCreateProgram();
    
    //5. Attach the shader objects to the shader program object
    glAttachShader(programObject, VertexShader);
    glAttachShader(programObject, FragmentShader);
    
    //6. Link both shader objects to the program object
    glLinkProgram(programObject);
    
    //6a. Make sure link had no errors
    glGetProgramiv(programObject, GL_LINK_STATUS, &testVal);
    if(testVal == GL_FALSE)
    {
        char infoLog[1024];
        glGetProgramInfoLog(programObject, 1024, NULL, infoLog);
        fprintf(stderr,"The programs %s and %s failed to link with the following errors:\n%s\n",
                uVertexShaderProgram, uFragmentShaderProgram, infoLog);
        glDeleteProgram(programObject);
        
    }else{
        fprintf(stderr,"Shaders linked successfully\n");
    }
    
	
    // These are no longer needed
    glDeleteShader(VertexShader);
    glDeleteShader(FragmentShader);
    
    //7. Use the program
    glUseProgram(programObject);
}


#pragma mark - Load, compile and link shaders to program

bool Character::loadShaderFile(const char *szFile, GLuint shader)
{
    GLint shaderLength = 0;
    FILE *fp;
	
    // Open the shader file
    fp = fopen(szFile, "r");
    if(fp != NULL)
    {
        // See how long the file is
        while (fgetc(fp) != EOF)
            shaderLength++;
		
        // Allocate a block of memory to send in the shader
        //assert(shaderLength < MAX_SHADER_LENGTH);   // make me bigger!
        if(shaderLength > MAX_SHADER_LENGTH)
        {
            fclose(fp);
            return false;
        }
		
        // Go back to beginning of file
        rewind(fp);
		
        // Read the whole file in
        if (shaderText != NULL)
            fread(shaderText, 1, shaderLength, fp);
		
        // Make sure it is null terminated and close the file
        shaderText[shaderLength] = '\0';
        fclose(fp);
    }
    else
        return false;
	
    // Load the string
    loadShaderSrc((const char *)shaderText, shader);
    
    return true;
}

// Load the shader from the source text
void Character::loadShaderSrc(const char *szShaderSrc, GLuint shader)
{
    GLchar *fsStringPtr[1];
    
    fsStringPtr[0] = (GLchar *)szShaderSrc;
    glShaderSource(shader, 1, (const GLchar **)fsStringPtr, NULL);
}

#pragma mark - Tear down of OpenGL
void Character::teadDownOpenGL(){
    
    glDeleteBuffers(1, &vertexBufferObject);
    glDeleteVertexArraysOES(1, &vertexArrayObject);
    
    
    if (programObject) {
        glDeleteProgram(programObject);
        programObject = 0;
        
    }
    
}