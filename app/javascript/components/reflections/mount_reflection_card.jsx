import { createRoot } from "react-dom/client";
import ReflectionCard from "./ReflectionCard";

let root;

export function mountReflection() {
  const el = document.getElementById("reflection-card-root");
  if (!el) return;

  root = createRoot(el);
  root.render(<ReflectionCard />);
}

export function unmountReflection() {
  if (root) {
    root.unmount();
    root = null;
  }
}

