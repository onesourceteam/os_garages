/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,svelte}"],
  theme: {
    extend: {
      colors: {
        main: "#f33",
      },
      animation: {
        fade: "fadeIn ease 1s",
      },
    },
  },
};
