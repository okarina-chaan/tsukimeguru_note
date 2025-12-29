import React, { useState } from "react";
import { PuffLoader } from "react-spinners";

function ReflectionCard() {

  const [status, setStatus] = useState("idle");
  const [weeklyInsightId, setWeeklyInsightId] = useState(null);

    const fetchReflection = async () => {
        setStatus("loading");
        try {
            const id_response = await fetch("/api/weekly_insights", {method: "POST"})
            const data = await id_response.json();
            setWeeklyInsightId(data.id);

            // APIの呼び出し
            const newId = data.id;
            setWeeklyInsightId(newId);
            const response = await fetch(`/api/weekly_insights/${newId}/fragment`)

            if (response.status === 200) {
                const html = await response.text();
                const target = document.getElementById("weekly-insight-root");
                if (target) target.innerHTML = html;
                setStatus("done");
                return;
            }

            if (response.status === 404) {
              setStatus("idle");
              return;
            }


        } catch (error) {
            console.error("fetchReflection error:", error);
            setStatus(error);
            setStatus("idle");
        }
      };

    if (status === "done") {
        return null;
    }
    
    return (
        <div className="reflection-card">
          <p>status: {status}</p>

          <div className={`status-${status}`}>
            {status === "idle" && "Idle"}
            {status === "loading" && (
              <div className="loading-indicator">
                <PuffLoader
                color="#E2E8F0"
                loading
                size={45}
                aria-label="Loading Spinner"
                data-testid="loader"
                />
              </div>
            )}
            {status === "done" && "Done!"}
            {status === "error" && "Error!"}
          </div>

          <div className="reflection-button">
            { status === "idle" ? <button onClick={fetchReflection}>
              今週を振り返る</button> : null }
          </div>
        </div>
    );
}

export default ReflectionCard;