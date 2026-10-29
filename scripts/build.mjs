import { build } from 'vite';
import { writeFile } from 'node:fs/promises';

await build();

function html(prefix) {
  return `<!doctype html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="theme-color" content="#176b4d">
<<<<<<< HEAD
  <title>Hola Yair | Inventario y producción</title>
  <link rel="stylesheet" href="${prefix}panmaster.css">
</head>
<body>
  <div id="root"><div style="font-family:Arial,sans-serif;padding:32px"><h1>Abriendo Hola Yair…</h1><p id="inicio-estado">Cargando la aplicación.</p></div></div>
=======
  <title>Panadería | Inventario y producción</title>
  <link rel="stylesheet" href="${prefix}panmaster.css">
</head>
<body>
  <div id="root"><div style="font-family:Arial,sans-serif;padding:32px"><h1>Abriendo PanMaster…</h1><p id="inicio-estado">Cargando la aplicación.</p></div></div>
>>>>>>> cb811b9add1323c52fbe743c4b346b08e7c7b466
  <script>
    window.panmasterLoadError = function () {
      var status = document.getElementById('inicio-estado');
      if (status) status.textContent = 'No se pudo cargar la aplicación. Extrae la carpeta completa del ZIP y conserva index.html junto a la carpeta publicacion. Después vuelve a abrir index.html.';
    };
    window.addEventListener('error', function () { window.panmasterLoadError(); });
  </script>
  <script defer src="${prefix}panmaster.js" onerror="panmasterLoadError()"></script>
<<<<<<< HEAD
  <noscript>Activa JavaScript en tu navegador para abrir Hola Yair.</noscript>
=======
  <noscript>Activa JavaScript en tu navegador para abrir PanMaster.</noscript>
>>>>>>> cb811b9add1323c52fbe743c4b346b08e7c7b466
</body>
</html>
`;
}

await writeFile('publicacion/index.html', html('./'), 'utf8');
await writeFile('publicacion/.nojekyll', '', 'utf8');
await writeFile('index.html', html('./publicacion/'), 'utf8');
await writeFile('.nojekyll', '', 'utf8');
console.log('Listo: index.html se abre directamente; publicacion/ está preparada para Pages.');
