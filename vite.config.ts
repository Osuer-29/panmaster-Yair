import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig(({ mode, command }) => ({
  base: './',
  plugins: [react()],
  define: command === 'build' ? {
    'process.env.NODE_ENV': JSON.stringify('production'),
  } : {},
<<<<<<< HEAD
  build: {
=======
  build: mode === 'desktop' ? {
    outDir: 'dist',
    emptyOutDir: true,
  } : {
>>>>>>> cb811b9add1323c52fbe743c4b346b08e7c7b466
    outDir: 'publicacion',
    emptyOutDir: true,
    cssCodeSplit: false,
    minify: true,
    lib: {
      entry: 'src/main.tsx',
      name: 'PanMaster',
      formats: ['iife'],
      fileName: () => 'panmaster.js',
      cssFileName: 'panmaster',
    },
<<<<<<< HEAD
    rollupOptions: { output: { inlineDynamicImports: true } },
=======
    rollupOptions: {
      output: { inlineDynamicImports: true },
    },
>>>>>>> cb811b9add1323c52fbe743c4b346b08e7c7b466
  },
  server: { host: '0.0.0.0' },
  preview: { host: '0.0.0.0' },
}));
