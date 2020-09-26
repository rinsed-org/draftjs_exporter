# frozen_string_literal: true

module DraftjsExporter
  module Atomic
    class Base
      def initialize(document, block, blocks, entity)
        @block = block
        @document = document
        @blocks = blocks
        @data = entity.fetch(:data)
      end

      def self.create(document, block, blocks, entity)
        new(document, block, blocks, entity).create
      end
    end
  end
end
