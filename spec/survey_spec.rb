require "spec_helper"

RSpec.describe Mumble::Survey do
  let(:account) do
    instance_double(Mumble::Account, name: "Culture Amp")
  end

  subject(:survey) do
    Mumble::Survey.new(
      account: account,
      name: "Engagement Survey"
    )
  end

  it "has an account" do
    expect(survey.account).to eq(account)
  end

  it "has a name" do
    expect(survey.name).to eq("Engagement Survey")
  end

  it "knows the account name" do
    expect(survey.account_name).to eq("Culture Amp")
  end

  it "has responses" do
    response = instance_double(Mumble::Response)
    survey.add_response(response)
    expect(survey.responses.count).to eq(1)
  end

  it "has questions" do
    question = instance_double(Mumble::Question)
    survey.add_question(question)
    expect(survey.questions.count).to eq(1)
  end

  context "answers_for" do
    let(:question) { instance_double(Mumble::Question) }

    context "when a survey has responses with answers" do
      let(:responses) { instance_double(Mumble::Responses) }

      before do
        allow(survey).to receive(:responses) { responses }
        allow(responses).to receive(:answers_for_question) { [1, 2] }
      end

      it "can find answers for specific questions" do
        expect(survey.answers_for_question(question)).to eq([1, 2])
      end
    end
  end

  context "responses_for_segments" do
    context "when a survey has responses with answers" do
      let(:responses) { instance_double(Mumble::Responses) }
      let(:response) { instance_double(Mumble::Response) }
      let(:segments) { [instance_double(Mumble::Segment)] }

      before do
        allow(survey).to receive(:responses) { responses }
        allow(responses).to receive(:for_segments) { [response] }
      end

      it "can find answers for specific questions" do
        expect(survey.responses_for_segments(segments)).to eq([response])
      end
    end
  end
end
