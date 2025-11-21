import daisyui from "daisyui"

export default {
  content: ["./app/views/**/*.{erb,html}", "./app/javascript/**/*.js"],
  theme: { extend: {} },
  plugins: [daisyui],
}
