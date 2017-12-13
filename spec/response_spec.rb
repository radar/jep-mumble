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
end
