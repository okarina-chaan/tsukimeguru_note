export default function Dashboard({
  today,
  event,
  moonPhaseName,
  moonPhaseEmoji,
  canCreateMoonNote
}) {
  return (
    <div className="min-h-screen py-10 px-4 bg-base-100 text-base-content">
      <div className="max-w-3xl mx-auto space-y-10">

        {/* 日付 & 月相表示 */}
        <div className="text-center space-y-3">
          <h2 className="text-xl font-display">{today}</h2>
          {event ? (
            <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full
                            bg-primary text-primary-content shadow-lg
                            border border-primary-content/20">
              <span className="text-2xl">{moonPhaseEmoji}</span>
              <span className="font-semibold text-lg">
                今日は {moonPhase} です
              </span>
            </div>
          ) : (
            <p className="text-lg text-base-content/80">
              今日はどんな1日でしたか？
            </p>
          )}

          <p className="text-lg mt-4 font-medium">
            今日はどんな記録を残しますか？
          </p>
        </div>

        {/* カード部分 */}
        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Daily Note */}
          <a
            href="/daily_notes/new"
            className="card bg-base-200 shadow-lg rounded-2xl p-6 border border-base-300
                       transition-all duration-300 hover:shadow-[0_0_20px_rgba(200,200,255,0.35)]
                       hover:border-primary cursor-pointer"
          >
            <div className="text-center space-y-3">
              <div className="text-3xl">📝</div>
              <h3 className="text-xl font-bold">Daily Noteを書く</h3>
              <p className="text-sm opacity-80">気分・体調・振り返り・自由メモ</p>
            </div>
          </a>

          {/* Moon Note 判定 */}
          {event ? (
            <a
              href="/moon_notes/new"
              className="card bg-primary text-primary-content shadow-lg rounded-2xl p-6 border border-primary/40
                         transition-all duration-300 hover:shadow-[0_0_25px_rgba(250,240,180,0.45)]
                         hover:border-primary-content cursor-pointer"
            >
              <div className="text-center space-y-3">
                <div className="text-3xl">🌙</div>
                <h3 className="text-xl font-bold">Moon Noteを書く</h3>
                <p className="text-sm opacity-90">{eventName} のメッセージを書きましょう</p>
              </div>
            </a>
          ) : canCreateMoonNote ? (
            <a
              href="/moon_notes/new"
              className="card bg-base-200 text-base-content shadow-md rounded-2xl p-6 border border-primary/30
                         transition-all duration-300 hover:shadow-[0_0_20px_rgba(200,200,255,0.2)]
                         hover:border-primary cursor-pointer"
            >
              <div className="text-center space-y-3">
                <div className="text-3xl">🌙</div>
                <h3 className="text-xl font-bold">Moon Noteを書く</h3>
                <p className="text-sm opacity-80">今日は作成できます</p>
              </div>
            </a>
          ) : (
            <div
              className="card bg-base-200 text-base-content/50 shadow-inner rounded-2xl p-6 border border-base-300
                         opacity-60 cursor-not-allowed"
            >
              <div className="text-center space-y-3">
                <div className="text-3xl">🌙</div>
                <h3 className="text-xl font-bold">Moon Noteは作成できません</h3>
                <p className="text-sm">今日は対象日ではありません</p>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

