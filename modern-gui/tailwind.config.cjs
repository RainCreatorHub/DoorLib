/** @type {import('tailwindcss').Config} */
module.exports = {
  darkMode: 'class',
  content: ['./index.html', './src/**/*.{ts,tsx}'],
  theme: {
    extend: {
      container: { center: true, padding: '1rem', screens: { '2xl': '1280px' } },
    },
  },
  plugins: [],
};
