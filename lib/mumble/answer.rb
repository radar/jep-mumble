module Mumble
  class Answer
    attr_reader :question, :value

    def initialize(question:, value:)
      @question = question
      @value = value
    end

    def belong_to_question?(other_question)
      question == other_question
    end
  end
end
