module.exports = {
  content: [
    "./app/views/**/*.{html.erb,erb}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.{js,ts}",
  ],
  theme: { extend: {} },
  plugins: [require("daisyui")],
  safelist: [
    'card-moon',
  ]
  daisyui: {
    themes: ["tsukimeguru-dark"],
    darkTheme: "tsukimeguru-dark",
    base: false,
  },
};
