module Mumble
  class Survey
    attr_reader :account, :name, :responses, :questions

    def initialize(account:, name:)
      @account = account
      @name = name
      @responses = []
      @questions = []
    end

    def account_name
      @account.name
    end

    def add_response(response)
      @responses << response
    end

    def add_question(question)
      @questions << question
    end

    def answers_for(question)
      @responses.flat_map(&:answers).select do |answer|
        answer.question == question
      end.map(&:value)
    end
  end
end
