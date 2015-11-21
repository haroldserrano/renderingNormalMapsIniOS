#Rendering Normal Maps using OpenGL ES 2.0 in iOS

## Introduction
Polygon count is important in computer graphics, especially in mobile devices, where resources are limited. You want to design your 3D model with the minimum count of polygons, yet provide enough artistic detail to be commercially acceptable.

Up to now, our lighting simulation has been effective in lighting our model, but has not taken care of minor details. This is where a technique called **Normal Mapping** can help. *Normal Mapping* is a technique that adds realism by creating the illusion of light bouncing off bumps or dents. 

### Objective
In this project, you will learn how to add realism to a 3D model by implementing **Normal Mapping** techniques. At the end of this project you will know how to apply *normal mapping* techniques to a 3D model in a mobile device as shown in figure 1.

##### Figure 1. A 3D model with normal mapping in iOS device
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/normalMappingiOS.png "normal mapping in iOS")

This is a hands on project. Download the [template Xcode project](https://dl.dropboxusercontent.com/u/107789379/haroldserrano/MakeOpenGLProject/Applying%20a%20normal%20map/Template-Skeleton.zip) and feel free to code along.


### Things to know
I would recommend for you to read these posts before starting this project.

* [How to apply a texture to a 3D model](http://www.haroldserrano.com/blog/how-to-apply-textures-to-a-character-in-ios)
* [How to apply lighting in OpenGL ES](http://www.haroldserrano.com/blog/anatomy-of-light-in-computer-graphics)

### Understanding Normal Mapping
#### Overview
Let’s talk briefly how lighting works. Light needs a surface to interact. A surface can be represented mathematically by a plane. The direction that the plane is facing is determined by a vector orthogonal to the plane. This orthogonal vector is called the *normal* vector. 

How bright a surface is lit depends on the angle between a normal vector and light direction vector. A light vector is simply a vector generated at the light source and ending at the surface location. If the angle between the light vector and the normal vector is small, the surface will contain a huge amount of light. If the angle is large, the surface will be lit only slightly. This is represented mathematically as shown in listing 1.

##### Figure 2. How light works with normal vectors
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/Normal%20vector%20and%20light.png)
##### Listing 1
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/amountOfLight.png)

A triangle primitive is constructed from vertices. Each vertex contains a normal vector. If we were to simulate lighting using the vectors at each edge of the triangle, the lighting will not look as smooth. But if we were to interpolate the normal vectors in each triangle, the lighting will be smoother. The lighting simulation using this technique creates a nice result. The problem is that it does not take care of details that can create realism.

So, what if instead of using the normal vectors found in the geometry of the 3D model, we create the **normal** vectors from our texture image instead? This is the idea of *Normal Mapping*. We use the **normal** vectors that will interact with our lighting equations from a texture, not from the geometry.

The mathematics to create **normal** vectors from textures is quite complex. Fortunately, there are applications that will calculate these vectors from your texture and save them in image format.

The application *[CrazyBump](http://www.crazybump.com/)* is a great application for creating **normal maps** from a diffuse texture. Figure 3 shows the **normal map** of the texture used in our 3D model.

##### Figure 3. Diffuse texture with Normal Map
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/crazybumpresult.png "CrazyBump result")

#### Normal Map Space
The creation of a **normal map** requires a new space system. This space system is composed of three orthogonal vectors: **normal**, **tangent** and **bitangent** vector. This space system is known as *Tangent Space*. 

In his book **[Mathematics for 3D Game Programming and Computer Graphics](http://www.amazon.com/exec/obidos/tg/detail/-/1435458869)**, Eric Lengyel provides an explanation on how to calculate the **Tangent** and **Bitangent** vectors. Listing 2 shows how this is done.

##### Listing 2. Calculating Tangent and Bi-Tangent Vectors
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/CalculatingTangentVectors.png "Calculating Tangent Vectors")

Where **Q** represents a point in a triangle and **s** and **t** represent the **UV** coordinates.

Once we have the **normal**, **tangent** and **bitangent** vectors for each vertex, we can transform from **Tangent Space** to **Model-World-View Space** using the matrix shown in listing 3.

##### Listing 3. Tangent Space to Model-World Space matrix
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation6.png "Tangent Space to MWS matrix")

Our lighting equation is calculated in the **Model-World-View Space**. Whereas, the **normal map** was calculated in **Tangent Space**. To use the **normal map** in our lighting equation, we need to transform it from **Tangent Space** to **Model-Wold-View Space**. Or transform our lighting parameters from **Model-World-View Space** to **Tangent Space**.

We could use either transformation. In this project will transform the lighting parameters from **Model-World-View Space** to **Tangent Space** by using the inverse of the matrix in listing 3. 

##### Listing 4. Model-World Space to Tangent Space matrix
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation7.png "MWS to Tangent Space Matrix")

You may have noticed that matrix in listing 4 is the transpose of the transformation matrix in listing 3. If the basis vectors in a space system are orthogonal to each other, the inverse of the matrix space is simply the transpose of the matrix space.

In our scenario, the three vectors, i.e., **normal**, **tangent** and **bitangent** may not be orthogonal. However, we can assume that they are close enough. We will orthogonalize each vector by using the **Gram-Schmidt** algorithm. Our new vectors are shown in listing 5.

##### Listing 5. Transpose of tangent and bitangent vectors

![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation8.png "tangent and bitanget vectors")

The **Bitangent** vector can simply be calculated by doing a cross operation on the vectors **N** and **T’**. However, we need to store the handedness of the vector **T’**, else the **bitangent** vector will point in the wrong direction. The subscript **w** in listing 5 represents the handedness of the **tangent** vector.

### Implementing Normal Map algorithm
Now that we know the mathematics behind *Normal Maps*, we are ready to implement it in code. Our goal is to calculate the **tangent** and **bitangent** vectors as shown in listing 2. Then create the transformation matrix as shown in listing 4. With this matrix, we can use it to transform our lighting parameters from **Model-World-View Space** to **Tangent Space**.

> The original implementation for calculating the tangent and bitangent vectors was developed by Eric Lengyel, and can be found here: [Computing Tangent Space Basis Vectors for an Arbitrary Mesh](http://www.terathon.com/code/tangent.html).

Open up the **Character.mm** file and head to the **calculateTangentVetors()** method. 

In this method we will only calculate the **tangent** vectors. Although we could also calculate the **bitangent** vectors. We will not do so. 

The reason is simply to save space in our OpenGL buffer. The **tangent** vectors will be calculated and loaded into a OpenGL buffer. The **bitangent** vectors will be calculated in the **Vertex** shader instead.

Copy what is shown in code-listing 1.

##### Code-Listing 1. Calculating the Tangent Vectors
<pre>
<code class="language-c">
void Character::calculateTangentVectors(){
//create vectors of GLKVectorX data type
vector&ltGLKVector3> vertex;
vector&ltGLKVector3> normal;
vector&ltGLKVector2> uvCoord;
vector&ltfloat> indexes;

//Craeate arrays of GLKVectorx data type
GLKVector3 tang[2*VERTEXCOUNT];
GLKVector3 bitang[2*VERTEXCOUNT];
GLKVector4 tangentVector[VERTEXCOUNT];



//1. load all vertices into a vector of GLKVector3 data type
for (int i=0; i&lt=VERTEXCOUNT-1;) {

GLKVector3 vertexValue=GLKVector3Make(smallHouse_vertices[i], smallHouse_vertices[i+1], smallHouse_vertices[i+2]);

vertex.push_back(vertexValue);

i=i+3;
}


//2. load all normal into a vector of GLKVector3 data type
for (int i=0; i&lt=VERTEXCOUNT-1;) {

GLKVector3 normalValue=GLKVector3Make(smallHouse_normal[i], smallHouse_normal[i+1], smallHouse_normal[i+2]);

normal.push_back(normalValue);

i=i+3;
}


//3. load all UV into a vector of GLKVector2 data type
for (int i=0; i&lt=UVCOUNT-1;) {

GLKVector2 uvValue=GLKVector2Make(smallHouse_uv[i], smallHouse_uv[i+1]);

uvCoord.push_back(uvValue);

i=i+2;
}

//4. load all indexes into a vector of float type
for (int i=0; i&lt=TRIANGLECOUNT-1; i++) {
indexes.push_back(smallHouse_index[i]);
}


for (int i=0; i&lt=TRIANGLECOUNT-1;) {

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

for (int a=0; a&lt=TRIANGLECOUNT-1;a++) {

GLKVector3 n=normal.at(a);
GLKVector3 t=tang[a];

//12. Orthogonalize the tangent vector with the Gram-Schmidt algorithm. See listing 5
GLKVector3 tangentTransposeVector=GLKVector3MultiplyScalar(n, GLKVector3DotProduct(n, t));
tangentTransposeVector=GLKVector3Subtract(t, tangentTransposeVector);
tangentTransposeVector=GLKVector3Normalize(tangentTransposeVector);

//13. Calculate handedness of the tangent vector
float handedness=(GLKVector3DotProduct(GLKVector3CrossProduct(n, t), bitang[a])&lt0.0f)?-1.0f:1.0f;

tangentVector[a]=GLKVector4Make(tangentTransposeVector.x, tangentTransposeVector.y, tangentTransposeVector.z, 0.0);

tangentVector[a].w=handedness;

}

int n=0;

for (int i=0; i&lt=TRIANGLECOUNT-1; i++) {

//14. Load the tangent data into the tangentVertices array to then be loaded into an OpenGL buffer.
smallHouse_tangent[i+3*n]=tangentVector[i].x;
smallHouse_tangent[i+1+3*n]=tangentVector[i].y;
smallHouse_tangent[i+2+3*n]=tangentVector[i].z;
smallHouse_tangent[i+3+3*n]=tangentVector[i].w;

n++;
}

}
</code>
</pre>

As it currently stands, our 3D model data is stored in **arrays**. To simplify our code, We are going to store these data into C++ vector data types as shown in lines 1-4. Each **vertex** and **normal** variable in this method contains a set of three coordinates. Whereas the **texture** variable contains a set of two coordinates.

A point **Q** inside a triangle can be defined as shown in listing 6.

##### Listing 6. Point Q in a triangle
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation1.png)

Where **P0** is the position of a vertex in the triangle and **T** and **B** are the **tangent** and **bitangent** vectors in the texture map, respectively. And **u** and **v** are the **UV** coordinates of the vertex.

What we want to do is assemble a triangle whose vertex positions are given by the points **P0**, **P1** and **P2**. And whose **UV** coordinates are given by the points **S** and **T**. By doing so, two points **Q1** and **Q2** in a triangle can be defined as shown in listing 7. We implement this step in line 7  in code.

##### Listing 7.
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation2.png)

and whose texture coordinates are defined as shown in listing 8. This is implemented in line 8 in code.

##### Listing 8.
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation3.png)

As shown in listing 6, both points **Q1** and **Q2** can now be defined as shown in listing 9.

##### Listing 9.

![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation4.png)

This is simply a linear system of equation which can be written in matrix form as shown in listing 10.

##### Listing 10.
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/math/tangentSpaceEquation5.png)

If we multiply both sides by the inverse of the **s,t** matrix, we get listing 2. Exactly what we are after; the values of the **Tangent** and **Bitangent** vectors. Listing 2 is implemented in code in lines 9-10.

Next, we simply average all the **tangent** and **bitangent** vectors for triangles sharing the same vertex (line 11).

As explained earlier, we are after the inverse matrix of the transformation matrix in listing 3. However, our vectors may not be completely orthogonal to each other. Thus, we need to orthogonalize them using the **Gram-Schmidt** algorithm. The orthogonalization of the **Tangent** vector is done in line 12 and its handedness is calculated in line 13.

Finally, we simply load our **Tangent** vectors into our **smallHouse\_tangent** array. This array will then be loaded into our OpenGL buffer.

### Loading our Tangent data into OpenGL buffers
Open up the file **Character.mm**. Go to the **setupOpenGL()** method and copy what is shown in code-listing 2.

##### Code-Listing 2. Loading tangent data
<pre>
<code class="language-c">
void Character::setupOpenGL(){

//...
//5. Dump the data into the Buffer
glBufferData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv)+sizeof(smallHouse_tangent), NULL, GL_STATIC_DRAW);

//...

//5d. Load Tangent data into glBufferSubData
glBufferSubData(GL_ARRAY_BUFFER, sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv), sizeof(smallHouse_tangent), smallHouse_tangent);
    
//...

//10d. Link the buffer data to the shader's tangent location
glVertexAttribPointer(tangentLocation, 4, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)(sizeof(smallHouse_vertices)+sizeof(smallHouse_normal)+sizeof(smallHouse_uv)));

//...

}
</code>
</pre>

The size of our buffer is increased by the size of the **smallHouse\_tangent** as shown in line 5.

Our **tangent** vector data is loaded into a OpenGL buffer using **glBufferSubData** as shown in line 5d.

We link the data in the buffer to the shader’s **tangentVector** location in line 10d.

### Load Normal Map Texture
Aside from loading our **diffuse** texture, we are also going to load our **normal map** texture into a texture buffer.  

##### Figure 4. A diffuse texture and a Normal Map Texture

![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/crazybumpresult.png "CrazyBump result")

Open up the file **Character.mm**. Go to the **setupOpenGL()** method and copy what is shown in code-listing 3.

##### Code-Listing 3. Loading a Normal Map texture
<pre>
<code class="language-c">
void Character::setupOpenGL(){

//...

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

//...

}
</code>
</pre>

The loading of a **Normal Map** texture is identical to loading any texture in a texture object buffer. We simply create a texture buffer that will contain our **normal map** texture (lines 19-21). We then decompress the image into raw format (line 21). Set the texture parameters as shown in line 22a-22b. Then we load the data into the texture buffer as shown in line 22c.

In line 23, we simply get the location of the uniform **Sampler2D**.

> If this is new to you, please read the post [How to apply a texture to a model in OpenGL](http://www.haroldserrano.com/blog/how-to-apply-textures-to-a-character-in-ios).

### Implementing the Shaders
We will use the same **vertex** and **fragment** shaders implemented in our post [How to apply lighting to a 3D model](http://www.haroldserrano.com/blog/anatomy-of-light-in-computer-graphics). The lighting equation found in this vertex is perfect for this project.

#### Implementing the Vertex Shader
Open up the **Shader.vsh** file and copy what is shown in code-listing 4. 

##### Code-Listing 4. Implementation of the vertex shader
<pre>
<code class="language-c">
//1. declare attributes
attribute vec4 position;
attribute vec3 normal;
attribute vec2 texCoord;
attribute vec4 tangentVector;

//...

//9. set tangent vector in view space
vec3 tangentVectorInViewSpace=normalize(normalMatrix*vec3(tangentVector));

//10. compute the binormal. See Listing 5
vec3 binormal=normalize(cross(normalInViewSpace,tangentVectorInViewSpace))*tangentVector.w;
    
//11. Transformation matrix from model-world-view space to tangent space. See Listing 4

mediump mat3 toTangentSpace=mat3(tangentVectorInViewSpace.x,binormal.x,normalInViewSpace.x,tangentVectorInViewSpace.y,binormal.y,normalInViewSpace.y,tangentVectorInViewSpace.z,binormal.z,normalInViewSpace.z);

//12. Transform the light position to model-view space
lightPosition=modelViewMatrix*lightPosition;

//13a. Transform the light to tangent space
lightPosition.xyz=normalize(toTangentSpace*(lightPosition.xyz));

//13.b Transform the vertex position to tangent space
positionInViewSpace.xyz=toTangentSpace*normalize(positionInViewSpace.xyz);

//...

</code>
</pre>

The modifications to this **vertex** shader are minimal.
In line 1 we simply add an attribute which will have a reference to our tangent vector data.

Line 9 simply transform the tangent attribute data into our **model-world-view** space.

As mentioned previously, the **bitangent** vector will be calculated in the **vertex** shader. Line 10 shows the calculation of this vector as defined in listing 5.

Our transformation matrix is calculated in line 11. This matrix was defined in listing 4 and is the transpose of the matrix in listing 3.
 
Finally, the light equation parameters are transformed from **model-world-view** space to **tangent space** as shown in lines 13a-13b.

#### Implementing the Fragment Shader
Open up the **Shader.fsh** file and copy what is shown in code-listing 5. 

##### Code-Listing 5. Implementation of the fragment shader
<pre>
<code class="language-c">

//...

//39. compute the ambient, diffuse and specular lights components but with the NORMAL TEXTURE INSTEAD
finalLightColor.rgb+=vec3(addAmbientDiffuseSpecularLights(positionInViewSpace,vec3(normalTexture.xyz)));

//40. Sample the texture using the Texture map and the texture coordinates
mediump vec4 textureColor=texture2D(DiffuseTextureMap,vTexCoordinates.st);


//...

</code>
</pre>

The main modification to the lighting equation is that it will now receive as input, the coordinates of the **Normal Map** texture. This is shown in line 39-40.

### Final Result
Run the project. Swipe your fingers horizontally across the screen. You should now see a light beam hitting the 3D model, creating the illusion of bumps and dents as shown in figure 5.

##### Figure 5. A 3D model with normal mapping in iOS device
![](https://dl.dropboxusercontent.com/u/107789379/CGDemy/blogimages/normalMappingiOS.png "normal mapping in iOS")

###Credit

###Question
