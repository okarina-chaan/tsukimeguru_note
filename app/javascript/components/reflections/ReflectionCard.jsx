import React, { useEffect, useState } from "react";
import { PuffLoader } from "react-spinners";
import axios from "../../../utils/axios";

function ReflectionCard() {
    const [status, setStatus] = useState("idle");
    const [available, setAvailable] = useState(null);
    const [nextDate, setNextDate] = useState(null);

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
            const res = await axios.post("/api/weekly_insights");
            const { id } = res.data;

            const fragment = await axios.get(`/api/weekly_insights/${id}/fragment`);
            const html = fragment.data;
            
            const target = document.getElementById("weekly-insight-root");
            if (target) target.innerHTML = html;

            setAvailable(false);
            setStatus("done");
        } catch (e) {
            console.error(e);
            setStatus("error");
        }
    };

    // dataset 読み込み待ち
    if (available === null) {
        return <p className="text-sm text-base-content/50">読み込み中...</p>;
    }

    return (
        <div className="flex flex-col gap-1">
            {!available && (
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

            {available && status === "idle" && (
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

            {status === "error" && (
                <div className="flex flex-col gap-2 items-center py-4">
                    <p className="text-sm text-error">
                        エラーが発生しました
                    </p>
                    <button
                        onClick={() => setStatus("idle")}
                        className="btn btn-sm btn-outline rounded-full px-4">
                        再試行
                    </button>
                </div>
            )}
        </div>
    );
}

export default ReflectionCard;
