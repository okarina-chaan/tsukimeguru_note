import "@hotwired/turbo-rails";
import "./controllers";

import { mountReflection, unmountReflection } from "./components/reflections/mount_reflection_card";

document.addEventListener("turbo:load", () => {
  mountReflection();
});

// ページキャッシュ前に React をアンマウントして二重マウントを防ぐ
document.addEventListener("turbo:before-cache", () => {
  unmountReflection();
});
