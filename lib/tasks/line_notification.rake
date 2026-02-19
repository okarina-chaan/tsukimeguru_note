namespace :line do
  desc "Moon Note対象日にLINE通知を送る"
  task notify_moon_note: :environment do
    today = Time.zone.today

    data = MoonApiService.fetch(today)
    return unless data.present?

    loose_phase = data[:loose_event]
    message = MoonNoteMessageService.message_for(loose_phase)
    return if message.nil?

    LineMessageSetting.enabled_for_phase(loose_phase).each do |setting|
      user = setting.user
      LineNotificationService.notify(user, message)
      setting.update!(last_notified_at: Time.zone.now)
    end
  end
end
