TECHTOOLKIT MODULAR
===================

Estructura:
- bootstrap.ps1              Lanzador remoto
- TechToolkit.ps1            Menu principal
- Core\UI.ps1               Interfaz de consola
- Core\Common.ps1           Funciones compartidas
- Modules\*.ps1             Funciones por categoria
- Config\settings.json      Configuracion

DESARROLLO LOCAL
----------------
Ejecuta Launch-TechToolkit.cmd.

PUBLICACION WEB
---------------
Sube TODOS los archivos conservando las carpetas.

Ejemplo:
https://midominio.com/TechToolkit/bootstrap.ps1
https://midominio.com/TechToolkit/TechToolkit.ps1
https://midominio.com/TechToolkit/Core/UI.ps1
...

En bootstrap.ps1 cambia:
$BaseUrl = "https://TU-DOMINIO/TechToolkit"

Despues podras ejecutar:
irm https://midominio.com/TechToolkit/bootstrap.ps1 | iex

IMPORTANTE
----------
Usar "irm ... | iex" ejecuta codigo remoto directamente.
Para uso profesional se recomienda:
- Servir siempre por HTTPS.
- Mantener tu repositorio bajo tu control.
- No aceptar parametros arbitrarios desde la URL.
- Probar cada version antes de publicarla.
- Idealmente agregar hashes/firma de archivos en versiones posteriores.
