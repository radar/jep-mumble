require "spec_helper"

RSpec.describe Mumble::User do
  let(:segment_1) { instance_double(Mumble::Segment, name: "Melbourne") }
  let(:segment_2) { instance_double(Mumble::Segment, name: "Male") }

  subject(:user) do
    Mumble::User.new(segments: [segment_1])
  end

  it "has segments" do
    expect(user.segments).to eq([segment_1])
  end

  context "has_segment?" do
    it "returns true if the user has a segment" do
      expect(user).to have_segment(segment_1)
    end

    it "returns fale if the user has a segment" do
      expect(user).not_to have_segment(segment_2)
    end
  end
end
