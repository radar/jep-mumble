require 'forwardable'

module Mumble
  class Responses
    extend Forwardable
    delegate %i(<< count) => :@responses

    attr_reader :responses

    def initialize(responses = [])
      @responses = responses
    end

    def answers_for_question(question)
      @responses.map { |response| response.answer_for_question(question) }
    end

    def segmented(*segments)
      @responses.select do |response|
        segments.all? { |segment| response.in_segment?(segment) }
      end
    end
  end
end
