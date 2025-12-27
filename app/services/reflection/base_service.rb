# リフレクションサービスのベースクラス
module Reflection
  class BaseService
    def call
      raise NotImplementedError
    end
  end
end