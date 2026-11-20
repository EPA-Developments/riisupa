# RIISUPA — Sitio institucional

Sitio web institucional de la **Red de Investigación e Innovación en Salud de Universidades de Gestión Privada de Argentina**. HTML5 estático, sin dependencias de build.

En esta etapa el sitio funciona como **portal de visibilidad**: información general de la Red, nodos temáticos, autoridades, integrantes, universidades con sus sedes y agenda de actividades.

## Inventario

```
riisupa/
├── index.html            Portada: presentación, nodos temáticos, calendario
│                         compartido (efemérides e iniciativas institucionales),
│                         agenda (próximos eventos) y últimas actividades.
├── la_red.html           Quiénes somos, estructura institucional, Comité
│                         Ejecutivo, Asamblea de Miembros (todos los integrantes,
│                         agrupados por universidad) y contacto oficial.
├── universidades.html    Las 20 universidades miembro con sus sedes por
│                         provincia, filtros y presencia federal.
├── eventos.html          Actividades: próximas y archivo.
├── robots.txt · sitemap.xml · favicon.svg
├── despliegue/          Configuración de nginx y script de verificación
│                         del sitio publicado (www.riisupa.org).
└── assets/
    ├── css/riisupa.css   Todo el estilo: paleta, tipografía, componentes.
    ├── img/              Logo e isotipo de la Red (PNG con fondo transparente).
    └── js/
        ├── data.js       FUENTE ÚNICA DEL CONTENIDO.
        └── riisupa.js    Header, footer, filtros y formato de fechas.
```

Menú: **Inicio · La Red · Universidades · Actividades**.

El reglamento **no se publica en el sitio**: es un documento de funcionamiento interno de la Red.

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
| `RIISUPA.eventos` | Actividades (con plantilla comentada para cargar nuevas). Flyers en `assets/img/actividades/` | Portada, "Actividades" |

Al editar `data.js`, todas las páginas se actualizan solas. Algunas reglas:

- Cada integrante se vincula a su universidad con el `id` de la universidad (por ejemplo `universidad: 'usal'`).
- Las sedes se escriben con los mismos nombres de la lista `provincias` (por ejemplo `'Pcia. de Buenos Aires'`, `'CABA'`).
- Si un texto lleva apóstrofo (D'Angelo), va entre comillas dobles: `"Silvia D'Angelo"`.
- Las actividades de tipo `efemeride` o `iniciativa-institucional` aparecen en "Calendario compartido"; el resto, en "Próximos eventos de la Red". Cuando pasa la fecha, se mueven solas al archivo.
- En la portada, el bloque "Últimas actividades" muestra las 3 actividades ya realizadas más recientes (aparece solo si hay alguna). Si una actividad tiene `linkVideo`, se marca "Con grabación" y en la página Actividades muestra el botón "Ver grabación".

Origen de los datos actuales: planilla *Integrantes_Red_RIISUPA_oct.2026.xlsx* (solapas "Miembros web" y "Sedes") y documento *Web de RIISUPA*.

## Cambios de la versión de noviembre 2026

- **Portada**: se quitó "Iniciativa CRUP 2026"; nuevo texto de presentación; las líneas de investigación pasan a ser los **7 nodos temáticos** (solo el nombre); se quitó la sección de proyectos.
- **La Red**: nuevo texto institucional; se quitaron las tarjetas de los artículos 5, 6 y 12; Comité Ejecutivo con las autoridades vigentes (período 2025-2027); la Asamblea muestra a **todos los integrantes sin distinción titular/suplente**, con cargo y universidad.
- **Universidades**: 20 universidades (se sumaron Universidad de la Cuenca del Plata y Universidad ISALUD) con **sedes por provincia**.
- **Contenido de ejemplo eliminado**: proyectos, investigadores, blog, convocatorias, eventos y descripciones de universidades que eran de muestra.
- **Páginas eliminadas**: `proyectos.html`, `lineas_investigacion.html`, `convocatorias.html`, `blog.html`, `investigadores.html`, `mock_index.html` y la copia vieja de `js/`. Quedan en el historial de git si se quieren recuperar.
- **Reglamento**: se quitó del sitio (página, links y sitemap) porque es de uso interno.
- **Fechas**: las fechas cargadas solo con día ya no se muestran corridas al día anterior.
- **Logo** de la Red en el encabezado y el pie.

## Publicación

El sitio se publica en **https://www.riisupa.org** (canónico); `riisupa.org` redirige a www. Lo sirve nginx en el servidor de EPA, con la configuración de `despliegue/nginx/www-riisupa`.

Primera vez (en el servidor):

```bash
sudo cp despliegue/nginx/www-riisupa /etc/nginx/sites-available/www-riisupa
sudo ln -s /etc/nginx/sites-available/www-riisupa /etc/nginx/sites-enabled/
sudo mkdir -p /var/www/riisupa.org
sudo nginx -t && sudo systemctl reload nginx
sudo certbot --nginx -d www.riisupa.org -d riisupa.org
```

Publicar o actualizar el contenido (rama `main`), sin los archivos del repositorio que no son del sitio:

```bash
git clone --depth 1 https://github.com/EPA-Developments/riisupa.git /tmp/riisupa
sudo rsync -a --delete --exclude .git --exclude .well-known --exclude README.md --exclude LICENSE \
  --exclude despliegue/ --exclude riisupa_github_org_structure.svg /tmp/riisupa/ /var/www/riisupa.org/
rm -rf /tmp/riisupa
```

`sitemap.xml` y `robots.txt` ya apuntan a `https://www.riisupa.org/`.

Para verificar que todo quedó bien (DNS, certificado, redirecciones, páginas, lo que no debe verse, encabezados y, en el servidor, nginx y la renovación de Certbot):

```bash
sudo bash despliegue/verificar-sitio.sh
```

CSS y JS se revalidan en cada visita (`data.js` tiene todo el contenido), así que un cambio publicado se ve enseguida; imágenes y fuentes tienen caché de 30 días: si se reemplaza una imagen, conviene cambiarle el nombre.

## Decisiones editoriales vigentes

- **Contacto único**: `rediisupa@gmail.com` + LinkedIn (aprobado por Comisión de Comunicación).
- **Integrantes**: se muestran nombre, cargo y universidad; no se publican correos personales.
- **Comisiones ad hoc**: no se muestran activas.
- **Reglamento**: de uso interno, no se publica.

## Licencia

- Código: **MIT**
- Contenido editorial y documentación: **CC BY 4.0**
