require "rails_helper"
require "line/bot"

RSpec.describe MoonNoteMessageService do
  describe ".message_for" do
    it "新月のメッセージが返ること" do
      expect(MoonNoteMessageService.message_for(:new_moon)).to include("今日は新月のMoon Noteの日です。")
    end

    it "満月のメッセージが返ること" do
      expect(MoonNoteMessageService.message_for(:full_moon)).to include("今日は満月のMoon Noteの日です。")
    end

    it "上弦の月のメッセージが返ること" do
      expect(MoonNoteMessageService.message_for(:first_quarter_moon)).to include("今日は上弦の月のMoon Noteの日です。")
    end

    it "下弦の月のメッセージが返ること" do
      expect(MoonNoteMessageService.message_for(:last_quarter_moon)).to include("今日は下弦の月のMoon Noteの日です。")
    end

    it "該当しないフェーズの場合はnilが返ること" do
      expect(MoonNoteMessageService.message_for(:unknown_phase)).to be_nil
    end
  end
end
