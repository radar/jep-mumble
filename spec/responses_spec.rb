require "spec_helper"

RSpec.describe Mumble::Responses do
  context "answers_for" do
    let(:question) { instance_double(Mumble::Question) }
    let(:answer1) { instance_double(Mumble::Answer, question: question) }
    let(:answer2) { instance_double(Mumble::Answer, question: question) }
    let(:response1) { instance_double(Mumble::Response, answer_for_question: answer1) }
    let(:response2) { instance_double(Mumble::Response, answer_for_question: answer2) }

    subject(:responses) do
      Mumble::Responses.new([
        response1,
        response2
      ])
    end

    it "gets all the answers for a given question" do
      answers = responses.answers_for_question(question)
      expect(answers).to match_array([answer1, answer2])
    end
  end

  context "segmented" do
    let(:response1) { instance_double(Mumble::Response, within_segments?: true) }
    let(:response2) { instance_double(Mumble::Response, within_segments?: false) }
    let(:segment) { instance_double(Mumble::Segment) }

    subject(:responses) do
      Mumble::Responses.new([
        response1,
        response2
      ])
    end

    it "includes the first response" do
      expect(responses.for_segments(segment)).to include(response1)
    end

    it "does not include the second response" do
      expect(responses.for_segments(segment)).not_to include(response2)
    end
  end
end
