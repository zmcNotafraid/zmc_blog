# -*- encoding : utf-8 -*-
module Refinery
  class Version
    @major = 2
    @minor = 0
    @tiny  = 5
    @build = nil

    class << self
      attr_reader :major, :minor, :tiny, :build

      def to_s
        [@major, @minor, @tiny, @build].compact.join('.')
      end
    end
  end
end
