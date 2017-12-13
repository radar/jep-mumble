module Mumble
  class Segment
    attr_reader :name

    def initialize(name:)
      @name = name
    end
  end
end
