import React, { useEffect, useState } from "react";
import { PuffLoader } from "react-spinners";

function ReflectionCard() {
  const [status, setStatus] = useState("idle");
  const [available, setAvailable] = useState(null);
  const [nextDate, setNextDate] = useState(null);
  const [created, setCreated] = useState(false);

  // dataset 初期化（1回だけ）
  useEffect(() => {
    const root = document.getElementById("reflection-card-root");
    if (!root) return;

    console.log("dataset.available:", root.dataset.available);
    console.log("parsed available:", root.dataset.available === "true");

    setAvailable(root.dataset.available === "true");
    setNextDate(root.dataset.nextDate);
  }, []);

  const fetchReflection = async () => {
    setStatus("loading");
    try {
      const res = await fetch("/api/weekly_insights", { method: "POST" });
      const { id } = await res.json();

      const fragment = await fetch(`/api/weekly_insights/${id}/fragment`);
      if (!fragment.ok) throw new Error("fragment fetch failed");

      const html = await fragment.text();
      const target = document.getElementById("weekly-insight-root");
      if (target) target.innerHTML = html;

      setAvailable(false);
      setCreated(true);
      setStatus("done");
    } catch (e) {
      console.error(e);
      setStatus("idle");
    }
  };

  // dataset 読み込み待ち
  if (available === null) {
    return <p className="text-sm text-base-content/50">読み込み中...</p>;
  }

  return (
    <div className="flex flex-col gap-1">
      {!available && created &&(
        <>
          <button
            disabled
            className="btn btn-sm rounded-full px-5
                        border border-base-content/30
                        text-base-content/60
                        bg-transparent cursor-not-allowed">
            先週を振り返る
          </button>
          <p className="text-xs text-base-content/70">
            次の更新は {nextDate}
          </p>
          <p className="text-xs text-base-content/50">
            週に1回だけ振り返りを更新できます
          </p>
        </>
      )}

      {available && status === "idle" && !created &&(
        <button
          onClick={fetchReflection}
          className="btn btn-sm btn-outline rounded-full self-center px-5">
          先週を振り返る
        </button>
      )}

      {status === "loading" && (
        <div className="flex justify-center py-4">
          <PuffLoader
          color="#E2E8F0" 
          loading size={45} 
          aria-label="Loading Spinner" 
          data-testid="loader"
          />
        </div>
      )}
    </div>
  );
}

export default ReflectionCard;
