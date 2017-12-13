require "spec_helper"

RSpec.describe Mumble::Account do
  subject(:account) do
    Mumble::Account.new(
      name: "Culture Amp",
      email: "ryanbigg@cultureamp.com"
    )
  end

  it "has a name" do
    expect(account.name).to eq("Culture Amp")
  end

  it "has an email" do
    expect(account.email).to eq("ryanbigg@cultureamp.com")
  end
end