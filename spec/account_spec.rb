require "spec_helper"

describe Mumble::Account do
  it "has a name" do
    account = Mumble::Account.new(name: "Culture Amp")
    expect(account.name).to eq("Culture Amp")
  end
end