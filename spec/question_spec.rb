require "spec_helper"

RSpec.describe Mumble::Question do
  let(:survey) { instance_double(Mumble::Question) }
  subject(:question) { Mumble::Question.new(title: "Do you feel supported by your manager?") }

  it "has a title" do
    expect(question.title).to eq("Do you feel supported by your manager?")
  end

  it "has answers" do
    answer = instance_double(Mumble::Answer)
    question.add_answer(answer)
    expect(question.answers.count).to eq(1)
  end
end
