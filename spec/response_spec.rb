require "spec_helper"

RSpec.describe Mumble::Response do
  subject(:response) do
    Mumble::Response.new(user: user)
  end

  let(:user) { instance_double(Mumble::User) }
  let(:answer) { instance_double(Mumble::Answer) }

  it "has a user" do
    expect(response.user).to eq(user)
  end

  it "has answers" do
    response.add_answer(answer)
    expect(response.answers.count).to eq(1)
  end

  context "has_segment?" do
    let(:segment) { instance_double(Mumble::Segment) }

    context "when the user has a segment" do
      before { allow(user).to receive(:in_segment?) { true } }
      it "returns true" do
        expect(response).to be_in_segment(segment)
      end
    end

    context "when the user does not have a segment" do
      before { allow(user).to receive(:in_segment?) { false } }
      it "returns false" do
        expect(response).not_to be_in_segment(segment)
      end
    end
  end
end
