# frozen_string_literal: true

require 'draftjs_exporter/atomic/base'

module DraftjsExporter
  module Atomic
    class Image < Base
      def create
        @document.create_element('p', align: @data.fetch(:alignment, 'default')).tap do |el|
          if link
            el.inner_html = <<~HTML
              <a href="#{link}"><img src="#{src}"></a>
            HTML
          else
            el.inner_html = <<~HTML
              <img src="#{src}">
            HTML
          end
        end
      end

      private

      def src
        @data.fetch(:src)
      end

      def link
        @data.fetch(:link, @default_target_url)
      end
    end
  end
end
