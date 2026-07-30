/** Una sola paleta: piedra cálida + un acento. Nada más. */
export default {
  content: ['./app/**/*.{js,jsx}', './components/**/*.{js,jsx}'],
  theme: {
    extend: {
      colors: {
        // Escala neutra única (piedra cálida). Todo el gris del sitio sale de aquí.
        stone: {
          50:'#FAFAF9',100:'#F5F5F4',200:'#E7E5E4',300:'#D6D3D1',400:'#A8A29D',
          500:'#78716C',600:'#57534E',700:'#44403C',800:'#292524',900:'#1C1917',
        },
        // Acento único, usado con moderación: foco, activo, primario.
        accent: {
          50:'#F0F4F8',100:'#DDE6EE',300:'#9FB3C8',500:'#3E5C76',600:'#334E64',700:'#28404F',
        },
      },
      fontFamily: {
        sans: ['ui-sans-serif','-apple-system','BlinkMacSystemFont','Inter','Segoe UI','sans-serif'],
        // Tabulares para dinero: las columnas deben alinearse al centavo.
        mono: ['ui-monospace','SFMono-Regular','Menlo','monospace'],
      },
      borderRadius: { xl:'0.75rem', '2xl':'1rem' },
      boxShadow: {
        // Sombras casi imperceptibles. La jerarquía la da el espacio, no el drama.
        card:'0 1px 2px 0 rgb(28 25 23 / 0.04), 0 1px 3px 0 rgb(28 25 23 / 0.06)',
        lift:'0 4px 16px -2px rgb(28 25 23 / 0.08), 0 2px 6px -2px rgb(28 25 23 / 0.05)',
        panel:'0 24px 48px -12px rgb(28 25 23 / 0.18)',
      },
      transitionTimingFunction: { smooth:'cubic-bezier(0.22, 1, 0.36, 1)' },
    },
  },
  plugins: [],
}
