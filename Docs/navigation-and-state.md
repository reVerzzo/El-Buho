# MVP
## 1. Mapa de navegación
La aplicación utiliza un sistema de navegación híbrido basado en pestañas principales y navegación jerárquica:
* **Menú Principal (Pestañas):** Contiene Inicio (Lista libros), Búsqueda y Mis libros (Favoritos).
* **Desde Inicio:** Navegación hacia el Perfil (botón superior) y hacia el Detalle del libro (al seleccionar un elemento de la cuadrícula).
* **Desde Búsqueda:** Navegación hacia el Detalle del libro al seleccionar un resultado o búsqueda reciente.
* **Desde Mis libros:** Navegación hacia el Detalle del libro para ver la información de un libro guardado.

## 2. Información por pantalla
* **Inicio (Lista libros)**
  * **Muestra:** Cuadrícula con las portadas del catálogo de libros.
  * **Recibe:** Colección de libros desde el estado global o API.
  * **Modifica:** Ningún dato directamente (actúa como punto de entrada).
  * **Conserva:** Posición del scroll de la cuadrícula.

* **Búsqueda**
  * **Muestra:** Barra de entrada de texto y cuadrícula de libros Recientes.
  * **Recibe:** Texto de búsqueda ingresado por el usuario.
  * **Modifica:** El historial de búsquedas y resultados mostrados.
  * **Conserva:** El término de búsqueda actual y el caché de resultados recientes.

* **Favoritos (Mis libros)**
  * **Muestra:** Cuadrícula de libros guardados y un botón de edición (lápiz).
  * **Recibe:** Lista filtrada de libros marcados como favoritos.
  * **Modifica:** Permite remover libros de la lista mediante el modo de edición.
  * **Conserva:** Las preferencias de visualización y guardado del usuario.

* **Detalle del Libro**
  * **Muestra:** Imagen de portada, título, autor, descripción completa y botón de Me gusta (corazón).
  * **Recibe:** El modelo de datos o identificador del libro seleccionado.
  * **Modifica:** El estado de favorito del libro en cuestión (activar/desactivar corazón).
  * **Conserva:** No aplica.

* **Perfil (Nombre)**
  * **Muestra:** Avatar, Nombre, Correo, otros datos y opción de Cerrar sesión / Cambiar contraseña.
  * **Recibe:** Datos del usuario autenticado.
  * **Modifica:** El estado de la sesión activa de la aplicación.
  * **Conserva:** No aplica.

## 3. Organización del estado
* **Estado Global (Catálogo y Favoritos):** Los datos de los libros y su propiedad "es favorito" deben vivir en un estado global inyectado (ej. `EnvironmentObject` u `@Observable`). 
  * La pantalla Inicio, Mis libros y Detalle del Libro dependen del mismo dato. Si el usuario entra al detalle y marca el corazón, ese cambio debe reflejarse instantáneamente en la pestaña Mis libros sin necesidad de recargar o pasar datos manualmente entre pantallas.
* **Estado Global (Usuario):** La información del perfil y el estado de la sesión deben ser globales. 
  * Permite que cualquier vista sepa si hay una sesión activa y facilita la limpieza de datos al ejecutar Cerrar sesión en la vista de Perfil.
* **Estado Local (Búsqueda y UI):** El texto ingresado en la barra de búsqueda debe vivir localmente en la vista de Búsqueda (ej. `@State`). 
  * Ninguna otra pantalla necesita conocer qué está tecleando el usuario hasta que ese término se procese, por lo que encapsularlo mejora el rendimiento y la limpieza del código.

## 4. Estrategia de navegación
La navegación se implementará utilizando las siguientes estructuras de SwiftUI para respetar el comportamiento esperado de iOS:
* `TabView`: Se utilizará como contenedor principal (Root View) para alojar el menú inferior fijo con los tres accesos (Inicio, Lupa, Mis libros).
* `NavigationStack`: Cada pestaña del `TabView` tendrá su propio contenedor de navegación. Esto es crucial para que, al navegar de Inicio a Detalle del libro, la transición ocurra con una animación de push horizontal y SwiftUI provea automáticamente el botón de retroceso en la barra de navegación.
* `NavigationLink`: Se usará en los elementos de las cuadrículas (portadas de libros) para detonar el push hacia la vista de Detalle del Libro pasando el modelo correspondiente.
* `.sheet` o `NavigationLink`: Para acceder al Perfil desde el Inicio, se puede utilizar un enlace en el `toolbar` superior. Dependiendo de la experiencia deseada, puede presentarse como un modal superpuesto (`.sheet`) o como una pantalla adicional en la pila de navegación.

# Mapa de navegación

### Inicio (Lista de libros)

   ➔ Perfil (Acceso desde la barra superior)

   ![Inicio](pantalla1.jpg)
   
   ![Perfil](pantalla2.jpg)

   ➔ Detalle del libro (Al seleccionar un libro en la cuadrícula)

   ![Detalle](pantalla4.jpg)

   

 ### Búsqueda
   ➔ Detalle del libro (Al seleccionar un resultado o búsqueda reciente)

   ![Busqueda](pantalla5.jpg)

### Mis libros (Favoritos)
   ➔ Detalle del libro (Al seleccionar un libro guardado)

   ![Inicio](pantalla3.jpg)