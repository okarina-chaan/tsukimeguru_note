module MoonNotesHelper
  def moon_phase_icon(phase)
    case phase.to_s
    when "new_moon"         then "🌑"
    when "first_quarter"    then "🌓"
    when "full_moon"        then "🌕"
    when "last_quarter"     then "🌗"
    else "🌙"
    end
  end

  def moon_phase_name(phase)
    case phase.to_s
    when "new_moon"         then "新月"
    when "first_quarter"    then "上弦の月"
    when "full_moon"        then "満月"
    when "last_quarter"     then "下弦の月"
    else "月"
    end
  end
end
