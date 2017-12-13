module Mumble
  class Question
    attr_reader :title, :answers

    def initialize(title:)
      @title = title
      @answers = []
    end

    def add_answer(answer)
      @answers << answer
    end
  end
end
