require 'forwardable'

module Mumble
  class Responses
    extend Forwardable
    delegate %i(count) => :@responses

    attr_reader :response

    def initialize(responses = [])
      @responses = responses
    end

    def add(response)
      @responses << response
    end

    def answers_for_question(question)
      @responses.map do |response|
        response.answer_for_question(question)
      end
    end

    def for_segments(*segments)
      @responses.select { |response| response.within_segments?(segments) }
    end
  end
end
