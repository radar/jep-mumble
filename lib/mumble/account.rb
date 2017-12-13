module Mumble
  class Account
    attr_reader :name, :email

    def initialize(name:, email:)
      @name = name
      @email = email
    end
  end
end