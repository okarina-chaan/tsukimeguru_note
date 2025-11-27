import daisyui from "daisyui"

export default {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: { extend: {} },
  plugins: [daisyui],
  daisyui: {
    themes: ["light"],
  },
}
