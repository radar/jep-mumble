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

    def answer_for_question(question)
      answers.detect { |answer| answer.question == question }
    end

    def within_segments?(segments)
      segments.all? { |segment| in_segment?(segment) }
    end

    def in_segment?(segment)
      user.in_segment?(segment)
    end
  end
end
