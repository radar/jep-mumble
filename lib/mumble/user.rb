module Mumble
  class User
    attr_reader :segments

    def initialize(segments:)
      @segments = segments
    end

    def in_segment?(segment)
      segments.include?(segment)
    end
  end
end
