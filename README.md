Miembros del equipo
Alex Alcaide Arroyes & Marc Ramis Caldes

-------

Ejercicios seleccionados: 

## Post processing

Vignetting/Blur/Pixelate: Hemos implementado todos los post-process, pero a los post-process que le hemos dado un significado ha sido al Vignette y al Blur al adentrarse en el agua, simulando la visión borrosa que ocurre cuando miras debajo del agua con una mezcla de un vignette azul celeste.

Ubicación en proyecto: Todos los gestores de Post-process se encuentran en Assets/Scripts/... (con nombres similares a CustomBlurSettings), mientras que los shaders de dichos post-process se encuentran en Assets/Shaders/... (con nombres similares a CustomBlur).
Ubicación en escena: los objetos se llaman "PostPro" y dentro de Post-Process_Volumes se encuentra "Water".

Como probar la implementación:

- Desactivar o activar los post-process en el post-process global que hay en escena, "PostPro". 
- Meter la cámara en el agua para probar el post-process "Water" o cambiar el post-process a global.

Bloom: Hemos implementado en varios pases el proceso de dicha técnica de post-process, primero buscamos las zonas más brillantes, luego saturamos esos pixeles más brillantes, después se aplica el bur en horizontal y en vertical y finalmente se aplica la imagen del bloom modificada sobre la original de aquellos pixeles que son más brillantes. (Funciona con nuestro PBR shader)

Ubicación en proyecto: El shader se encuentra en Assets/Shader/Custom_Bloom. El gestor del shader Assets/Scripts/CustomBloomSettings.
Ubicación en escena: La bola que gira alrededor de la isla, que tiene un material emisivo de Unity, y todas las luces de nuestro PBR.

	- Shader in Unity

Adding features to our PBR shader: Hemos implementado en un segundo pase las sombras de nuestro PBR pero solo se visualizan en los objetos de Unity.

Ubicación en proyecto: Nuestro PBR se encuentra en Assets/Shaders/PBR, a partir de la linea 251.

Como probar la implementación:

- En la escena hay un plano de unity disabled llamado "Plane-TestShadows", si se activa se verán las sombras.

Create materials for the whole scene using your material: Todas los objetos de la escena excepto aquellos en los que específicamos que son texturas o materiales de Unity contienen los materiales de nuestro PBR con diferentes valores en sus propiedades.

Ubicación en proyecto: Nuestro PBR se encuentra en Assets/Shaders/PBR, mientras que los materiales usados para la escena están en Assets/Materials/... (con nombres similares a PBR-Flag). El código que gestiona el PBR se encuentra en Assets/Scripts/Light_PBR.

	- Compute Shaders

Boids Implementation: En esta simulación hemos decidido generar un grupo de boids que sigan un camino de puntos predefinidos esquivando los obstáculos. Los cálculos de dicha implementación se realizan parcialmente en el geometry shader y en unity, parcialmente porque hemos tenido errores de NaN que no hemos acabado solucionando y al final lo que hemos decidido hacer es realizar algunos cálculos de comportamientos en Unity y pasar el resultado de dicho comportamiento al geometry shader dónde se acabarían sumando todas las fuerzas.

Ubicación en proyecto: El Geometry shader se encuentra en Assets/Shaders/AI_Boids, mientras que el gestor del shader se encuentra en Assets/Scripts/SimpleComputePersistent.
Ubicación en escena: el objeto de boids se llama AI_Gestor.

Ubicación de dónde se calculan los comportamientos: Los comportamientos de Cohesión y Seek se calculan en el geometry shader (el target del seek varía desde unity), mientras que alignment, avoidance y separation se calculan desde unity (avoidance por el tema de usar raycasts, mientras que separation y alignment porque daban errores de cálculos NaN al dividir / 0).

Problemas no resueltos: 

- El que ya hemos comentado de los erorres de NaN, ocurre porque se divide / 0, el problema aquí, suponemos que el valor que tenemos para dividir el "average" de la fuerza calculada (en el geometry shader linea 78 del Separation) es 0 o directamente no está sumando al entrar en el for y por tanto al dividir entre 0 da error. El caso es que en la función de Cohesión (linea 36 inicia la función, en linea 55 se aplica la division) se aplica la misma lógica y no provoca errores de NaN.

- Neighbours, más o menos el mismo problema que arriba, que es como que el shader no declara bien ciertos valores, al intentar buscar los neighbours tampoco llegaba a sumar así que directamente lo que hemos hecho es que los neighbours de cada uno fueran todos los boids que pertenencen a su grupo. (en las lineas 45-50 se puede ver el intento de aplicar grupos vecinos y que dicha implementación provoca errores NaN)

Como probar la implementación:

- Se puede contemplar fácilmente que el avoidance funciona (porque su fuerza de peso es de 20).
- Pero para poder probar que alignment, separation y cohesion también funcionan debe colocarse un valor de peso mayor al valor de peso que tiene el comportamiento de seek (que es 9). Para hacerlo, en runtime se puede cambiar desde el inspector del objeto "AI_Gestor", cambiando Seek Force, Cohesion Force, Separation Force, Align Force.

	- Additional Implementations

Triplanar textures: Hemos creado un shader que mezcla dos texturas y según un valor de smoothness que puede modificarse en el material se ve predominante una o la otra textura.
Ubicación en proyecto: El shader puede encontrarse en la carpeta Assets/Shaders/Triplanar, el material en Assets/Materials/Triplanar_RockGrass.
Ubcación en escena: El objeto de la escena con el material que contiene este shader se llama "rock-sharp".

	- Rogue exercise

Implement multiple light handling & spotlight: Para hacer que el shader de PBR sea capaz de mostrar más de una luz de un mismo tipo, le pasamos desde el script un array con los datos necesarios para que las pueda calcular y en el shader pasa por un for donde va sumando el resultado de cada luz al resultado final. Para crear la spotlight calculamos el cono de luz que tendría que dar a traves de su posición, su dirección y el angulo de apuertura que tiene como máximo.

Ubicación en proyecto: Nuestro PBR se encuentra en Assets/Shaders/PBR, mientras que los materiales usados para la escena están en Assets/Materials/... (con nombres similares a PBR-Flag). El código que gestiona el PBR se encuentra en Assets/Scripts/Light_PBR.

Ubicación en escena: Todas las luces pueden encontrarse en un objeto llamado "Lights". El código que controla el PBR se encuentra dentro del gameObject Lights.

-------

No usamos shaders graphs.
