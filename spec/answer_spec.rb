require "spec_helper"

RSpec.describe Mumble::Answer do
  let(:question) { instance_double(Mumble::Question) }
  subject(:answer) do
    Mumble::Answer.new(question: question, value: 1)
  end

  it "has a question" do
    expect(answer.question).to eq(question)
  end

  it "has a value" do
    expect(answer.value).to eq(1)
  end
end
