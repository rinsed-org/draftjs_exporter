# frozen_string_literal: true

require 'draftjs_exporter/atomic/base'

module DraftjsExporter
  module Atomic
    class Image < Base
      def create
        @document.create_element('p', align: @data.fetch(:alignment, 'default')).tap do |el|
          el.add_child(@document.create_element('img', src: @data.fetch(:src)))
        end
      end
    end
  end
end
