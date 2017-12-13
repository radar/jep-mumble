module Mumble
  class Response
    attr_reader :user, :answers

    def initialize(user:)
      @user = user
      @answers = []
    end

    def add_answer(answer)
      @answers << answer
    end
  end
end
