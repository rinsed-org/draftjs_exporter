# frozen_string_literal: true

module DraftjsExporter
  module Atomic
    class Base
      def initialize(document, block, blocks, entity, default_target_url)
        @block = block
        @document = document
        @blocks = blocks
        @data = entity.fetch(:data)
        @default_target_url = default_target_url
      end

      def self.create(document, block, blocks, entity, default_target_url = nil)
        new(document, block, blocks, entity, default_target_url).create
      end
    end
  end
end
