# frozen_string_literal: true

module DraftjsExporter
  module Atomic
    class Base
      def initialize(document, block, blocks)
        @block = block
        @document = document
        @blocks = blocks
        @data = @block[:data]
      end

      def self.create(document, block, blocks)
        new(document, block, blocks).create
      end
    end
  end
end
