import { createRoot } from "react-dom/client";
import ReflectionCard from "./ReflectionCard";

/**
 * - 分析ページに <div id="reflection-root"> があるときだけ実行
 * - createRoot は1回だけ
 * - Turbo と一緒に安全に動く
 */
export function mountReflection() {
  const rootElement = document.getElementById("reflection-card-root");

  // 分析ページ以外では何もしない
  if (!rootElement) return;

  // Turboで戻ってきたときに二重マウントしないためのガード
  if (rootElement.dataset.mounted === "true") return;

  const root = createRoot(rootElement);
  root.render(<ReflectionCard />);

  // 保存しておけばアンマウントできる
  rootElement._reactRoot = root;
  rootElement.dataset.mounted = "true";
}

export function unmountReflection() {
  const rootElement = document.getElementById("reflection-card-root");
  if (!rootElement) return;
  if (rootElement._reactRoot) {
    rootElement._reactRoot.unmount();
    delete rootElement._reactRoot;
  }
  delete rootElement.dataset.mounted;
}
