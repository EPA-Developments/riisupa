# RIISUPA — Sitio institucional

Sitio web institucional de la **Red de Investigación e Innovación en Salud de Universidades de Gestión Privada de Argentina**. HTML5 estático, sin dependencias de build.

En esta etapa el sitio funciona como **portal de visibilidad**: información general de la Red, nodos temáticos, autoridades, integrantes, universidades con sus sedes y agenda de actividades.

## Inventario

```
riisupa/
├── index.html            Portada: presentación, nodos temáticos, calendario
│                         compartido (efemérides e iniciativas institucionales)
│                         y agenda (próximos eventos de la Red).
├── la_red.html           Quiénes somos, estructura institucional, Comité
│                         Ejecutivo, Asamblea de Miembros (todos los integrantes,
│                         agrupados por universidad) y contacto oficial.
├── universidades.html    Las 20 universidades miembro con sus sedes por
│                         provincia, filtros y presencia federal.
├── eventos.html          Actividades: próximas y archivo.
├── reglamento.html       Texto completo del reglamento, con índice y anchors
│                         por artículo.
├── robots.txt · sitemap.xml · favicon.svg
└── assets/
    ├── css/riisupa.css   Todo el estilo: paleta, tipografía, componentes.
    ├── img/              Logo e isotipo de la Red (PNG con fondo transparente).
    └── js/
        ├── data.js       FUENTE ÚNICA DEL CONTENIDO.
        └── riisupa.js    Header, footer, filtros y formato de fechas.
```

Menú: **Inicio · La Red · Universidades · Actividades**. El reglamento se accede desde "La Red", el pie de página y los links de cada página.

## Cómo editar el contenido

**Casi todo el contenido vive en `assets/js/data.js`**, organizado en listas:

| Lista | Contenido | Dónde se ve |
| --- | --- | --- |
| `RIISUPA.contacto` | Email y LinkedIn oficiales | Pie de página, "La Red" |
| `RIISUPA.nodos` | 7 nodos temáticos | Portada |
| `RIISUPA.comiteEjecutivo` | Presidente, Vicepresidente y Secretario, con universidad y período | "La Red" |
| `RIISUPA.universidades` | 20 universidades: nombre, sigla, sitio web y sedes (provincias) | "Universidades", "La Red" |
| `RIISUPA.integrantes` | 28 integrantes de la Asamblea: nombre, cargo y universidad | "La Red" |
| `RIISUPA.provincias` | Orden en que se listan las provincias | "Universidades" |
| `RIISUPA.eventos` | Actividades (vacía por ahora; tiene una plantilla comentada) | Portada, "Actividades" |

Al editar `data.js`, todas las páginas se actualizan solas. Algunas reglas:

- Cada integrante se vincula a su universidad con el `id` de la universidad (por ejemplo `universidad: 'usal'`).
- Las sedes se escriben con los mismos nombres de la lista `provincias` (por ejemplo `'Pcia. de Buenos Aires'`, `'CABA'`).
- Si un texto lleva apóstrofo (D'Angelo), va entre comillas dobles: `"Silvia D'Angelo"`.
- Las actividades de tipo `efemeride` o `iniciativa-institucional` aparecen en "Calendario compartido"; el resto, en "Próximos eventos de la Red". Cuando pasa la fecha, se mueven solas al archivo.

Origen de los datos actuales: planilla *Integrantes_Red_RIISUPA_oct.2026.xlsx* (solapas "Miembros web" y "Sedes") y documento *Web de RIISUPA*.

## Cambios de la versión de noviembre 2026

- **Portada**: se quitó "Iniciativa CRUP 2026"; nuevo texto de presentación; las líneas de investigación pasan a ser los **7 nodos temáticos** (solo el nombre); se quitó la sección de proyectos.
- **La Red**: nuevo texto institucional; se quitaron las tarjetas de los artículos 5, 6 y 12; Comité Ejecutivo con las autoridades vigentes (período 2025-2027); la Asamblea muestra a **todos los integrantes sin distinción titular/suplente**, con cargo y universidad.
- **Universidades**: 20 universidades (se sumaron Universidad de la Cuenca del Plata y Universidad ISALUD) con **sedes por provincia**.
- **Contenido de ejemplo eliminado**: proyectos, investigadores, blog, convocatorias, eventos y descripciones de universidades que eran de muestra.
- **Páginas eliminadas**: `proyectos.html`, `lineas_investigacion.html`, `convocatorias.html`, `blog.html`, `investigadores.html`, `mock_index.html` y la copia vieja de `js/`. Quedan en el historial de git si se quieren recuperar.
- **Reglamento**: se quitaron dos recuadros y un botón que describían trámites por GitHub que no forman parte del reglamento. El texto de los artículos no se modificó.
- **Fechas**: las fechas cargadas solo con día ya no se muestran corridas al día anterior.
- **Logo** de la Red en el encabezado y el pie.

## Publicación

El sitio es estático: cualquier hosting de archivos sirve (GitHub Pages, Netlify, el servidor de una universidad, etc.). `sitemap.xml` y `robots.txt` apuntan hoy a `https://riisupa.github.io/`; si el dominio final es otro, hay que actualizar esas dos URLs.

Para GitHub Pages: en **Settings → Pages**, "Deploy from a branch", branch `main`, carpeta `/ (root)`.

## Decisiones editoriales vigentes

- **Contacto único**: `rediisupa@gmail.com` + LinkedIn (aprobado por Comisión de Comunicación).
- **Integrantes**: se muestran nombre, cargo y universidad; no se publican correos personales.
- **Comisiones ad hoc**: no se muestran activas.

## Licencia

- Código: **MIT**
- Contenido editorial y documentación: **CC BY 4.0**
