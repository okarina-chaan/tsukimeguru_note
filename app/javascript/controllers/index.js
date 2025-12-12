import { application } from "./application"

import DailyNoteToggleController from "./daily_note_toggle_controller"
import DiaryEntryController from "./diary_entry_controller"
import HelloController from "./hello_controller"
import AnalysisChartController from "./analysis_chart_controller"
import FlashController from "./flash_controller"
import LoadingController from "./loading_controller"
import CalendarPageController from "./calendar_page_controller"

application.register("daily-note-toggle", DailyNoteToggleController)
application.register("diary-entry", DiaryEntryController)
application.register("hello", HelloController)
application.register("analysis-chart", AnalysisChartController)
application.register("flash", FlashController)
application.register("loading", LoadingController)
application.register("calendar-page", CalendarPageController)
