# El Buho - Prototipo de Aplicación Móvil
## Integrantes del equipo
1. Perez Hernandez Uriel Alexander
2. Corona Baez Fabrizzio Alessandro
## Descripción del Proyecto

---

## Flujo de Usuario y Pantallas

A continuación se detalla el recorrido principal del usuario dentro de la aplicación:

### 1. Pantalla Principal (Lista de Libros)
Una vez autenticado, el usuario llega al "Home", donde se presenta una cuadrícula con el catálogo de libros disponibles. Cuenta con una barra de navegación inferior para acceder rápidamente a las secciones clave de la app.
<img width="736" height="1600" alt="inicio" src="https://github.com/user-attachments/assets/455e9b94-34fb-43bb-8e5f-eee795b3fb54" />

#### 1.1 Secciones del incio.
Al tocar en el título de la seccioón del inicio se despliega una lista de libros relacionados.
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/7328795b-dd6a-45e1-ab4f-35daeed24951" />


### 2. Búsqueda
Accesible desde la barra de navegación inferior. Permite a los usuarios buscar títulos o autores específicos de manera rápida, mostrando resultados filtrados en formato de cuadrícula.
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/5aa0e16a-7e6e-4cff-839f-e3f981ec3ffd" />
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/df649f9c-d112-4d1c-b028-db947469a398" />

### 3. Favoritos
Sección dedicada donde los usuarios pueden consultar los libros que han marcado como favoritos para leerlos más tarde o tenerlos a mano.
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/04e92dd4-2c3b-4bcf-8d15-7df9dbedcfad" />

### 4. Detalle del Libro
Al tocar cualquier libro en las pantallas anteriores, el usuario accede a esta vista. Muestra la portada en gran tamaño, el título, el autor, una sinopsis detallada y los llamados a la acción ("Añadir a Favoritos").
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/612436ba-45b5-44e0-b254-e290d1528a62" />

#### 4.1 Pop-up del Autor.
Al tocar en el nombre del autor se despliega un pop-up que muestra una biografía corta del autor del libro.
<img width="736" height="1600" alt="image" src="https://github.com/user-attachments/assets/08ccb603-362c-4ede-bd38-f5bf01e8f94b" />

=======

# Guía de Accesibilidad para Wireframes

A continuación se detalla la configuración de accesibilidad para cada elemento esencial de las pantallas de la aplicación, incluye traits y el texto exacto que dictará el VoiceOver en iOS.

---

## Pantalla: Lista libros

*   **Texto "Lista libros"**
    *   **Configuración:** Trait `Encabezado`.
    *   **VoiceOver:** *"Lista libros, encabezado"*.
*   **Portadas de la cuadrícula (Libros)**
    *   **Configuración:** Actúan como botones interactivos. El `accessibilityLabel` debe ser el nombre de la obra.
    *   **VoiceOver dirá:** *"[Título del libro], botón. Toca dos veces para ver los detalles del libro"*.
*   **Barra de navegación inferior** *(Aplica a todas las pantallas)*
    *   **Configuración:** Elementos de navegación estándar de iOS.
    *   **VoiceOver dirá:** *"Inicio, pestaña, 1 de 3"*. Cuando el usuario seleccione otra sección, añadirá la palabra *"seleccionado"* antes del nombre de la pestaña.

---

## Pantalla: Búsqueda

*   **Texto "Búsqueda"**
    *   **Configuración:** Trait de `Encabezado` (`.header`).
    *   **VoiceOver dirá:** *"Búsqueda, encabezado"*.
*   **Barra de entrada de texto (Buscador)**
    *   **Configuración:** Trait de `Campo de búsqueda` (`.searchField`) e incluir un texto de marcador de posición (placeholder) descriptivo.
    *   **VoiceOver dirá:** *"Buscar por título o autor, campo de búsqueda. Toca dos veces para editar"*.
*   **Texto "Recientes"**
    *   **Configuración:** Asignar el trait de `Encabezado` (`.header`).
    *   **VoiceOver dirá:** *"Recientes, encabezado"*.
*   **Miniaturas recientes**
    *   **Configuración:** Heredan exactamente el mismo comportamiento y descripción que los libros de la pantalla principal.

---

## Pantalla: Favoritos

*   **Texto "Favoritos"**
    *   **Configuración:** Trait de `Encabezado` (`.header`).
    *   **VoiceOver dirá:** *"Favoritos, encabezado"*.
*   **Icono de lápiz (Editar)**
    *   **Configuración:** Evitar que el lector diga "lápiz". Asignarle un `accessibilityLabel` de acción clara y el trait de `Botón` (`.button`). Se recomienda añadir un `accessibilityHint`.
    *   **VoiceOver dirá:** *"Editar lista, botón. Toca dos veces para reordenar o eliminar libros"*.

---

## Pantalla: Detalle del libro

*   **Flecha superior izquierda (Regresar)**
    *   **Configuración:** Trait de `Botón` (`.button`).
    *   **VoiceOver dirá:** *"Atrás, botón"*.
*   **Icono de corazón (Favoritos)**
    *   **Configuración:** El `accessibilityLabel` debe cambiar dinámicamente según el estado en la base de datos (si ya está guardado o no).
    *   **VoiceOver dirá:** *"Añadir a favoritos, botón"* o *"Eliminar de favoritos, botón"*.
*   **Imagen principal (Portada)**
    *   **Configuración:** Si el gráfico es puramente decorativo, ocultarlo estableciendo `isAccessibilityElement = false`. Si representa la portada real, añadir descripción.
    *   **VoiceOver dirá:** *"Portada de [Título del libro], imagen"*.
*   **Texto "Libro 1" (Título general)**
    *   **Configuración:** Debe ser el punto de anclaje principal de la pantalla. Asignar el trait de `Encabezado` (`.header`).
    *   **VoiceOver dirá:** *"[Título del libro], encabezado"*.
*   **Texto "Autor"**
    *   **Configuración:** Agrupar el título "Autor" con el nombre real para que no se lean de forma aislada (usando `accessibilityElements`).
    *   **VoiceOver dirá:** *"Autor, [Nombre del autor]"*.
*   **Bloque de descripción (Sinopsis)**
    *   **Configuración:** Configurar como `Texto estático` (`.staticText`).
    *   **VoiceOver dirá:** *(Comenzará a leer en voz alta el contenido completo de la sinopsis sin añadir palabras extra).*


