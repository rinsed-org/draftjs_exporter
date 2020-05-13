# frozen_string_literal: true

module DraftjsExporter
  module Atomic
    class Base
      def initialize(document, block)
        @block, @document = block, document
        @data = @block[:data]
      end

      def self.create(document, block)
        new(document, block).create
      end
    end
  end
end