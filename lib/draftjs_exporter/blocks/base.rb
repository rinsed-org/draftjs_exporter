# frozen_string_literal: true

module DraftjsExporter
  module Blocks
    class Base
      def initialize(document, block)
        @block = block
        @document = document
        @data = @block[:data]
      end

      def self.create(document, block)
        new(document, block).create
      end
    end
  end
end
