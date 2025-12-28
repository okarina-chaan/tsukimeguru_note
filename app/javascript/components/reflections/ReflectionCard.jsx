import React, { useState } from "react";
import { PuffLoader } from "react-spinners";

function ReflectionCard() {

  const [status, setStatus] = useState("idle");

    const fetchReflection = async () => {
        setStatus("loading");
        try {
            // APIの呼び出し
            const response = await fetch("/api/weekly_insights", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json",
                },
            });

            if (!response.ok) {
                throw new Error("Network response was not ok");
            }

            // 必要に応じてレスポンスデータを処理
            const data = await response.json();
            const id = data.id;
            console.log("created id:", id);

            setStatus("success");
        } catch (error) {
            console.error(error);
            setStatus("error");
        }
      };

    if (status === "success") {
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
            {status === "success" && null}
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