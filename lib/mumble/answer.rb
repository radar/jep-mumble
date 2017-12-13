module Mumble
  class Answer
    attr_reader :question, :value

    def initialize(question:, value:)
      @question = question
      @value = value
    end
  end
end
