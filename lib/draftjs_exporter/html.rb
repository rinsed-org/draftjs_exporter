# frozen_string_literal: true

require 'nokogiri'
require 'draftjs_exporter/wrapper_state'
require 'draftjs_exporter/entity_state'
require 'draftjs_exporter/style_state'
require 'draftjs_exporter/command'

module DraftjsExporter
  class HTML
    attr_reader :block_map, :style_map, :entity_decorators, :style_block_map

    def initialize(block_map:, style_map:, entity_decorators:, style_block_map:)
      @block_map = block_map
      @style_map = style_map
      @entity_decorators = entity_decorators
      @style_block_map = style_block_map
    end

    def call(content_state, options = {})
      blocks = content_state.fetch(:blocks, [])
      entity_map = content_state.fetch(:entityMap, {})
      wrapper_state = WrapperState.new(block_map, blocks, entity_map)

      blocks.each do |block|
        element = wrapper_state.element_for(block)
        block_contents(element, block, entity_map)
      end

      wrapper_state.to_html options
    end

    private

    def block_contents(element, block, entity_map)
      style_state = StyleState.new(style_map, style_block_map)
      entity_state = EntityState.new(element, entity_decorators, entity_map)
      build_command_groups(block, entity_map).each do |text, commands|
        commands.each do |command|
          entity_state.apply(command)
          style_state.apply(command)
        end

        add_node(entity_state.current_parent, text, style_state)
      end
    end

    def add_node(element, text, style_state)
      document = element.document
      parent = build_nested_tag_element(style_state.element_style_tags, element)

      if style_state.text?
        node = cdata_node(document, text)
      else
        node = document.create_element('span', style_state.element_attributes)
        node.add_child(cdata_node(document, text))
      end

      parent.add_child(node)
    end

    # Return the last tag
    def build_nested_tag_element(tags, parent)
      document = parent.document

      tags.reduce(parent) do |last_parent, tag|
        current_node = document.create_element(tag)
        last_parent.add_child(current_node)
        current_node
      end
    end

    def build_command_groups(block, entity_map)
      grouped = build_commands(block).group_by(&:index).sort
      grouped.map.with_index { |(index, commands), command_index|
        start_index = index
        next_group = grouped[command_index + 1]
        stop_index = (next_group && next_group.first || 0) - 1

        text = block.fetch(:text).slice(start_index..stop_index)

        entity_range = block.fetch(:entityRanges).detect{ |e| e.fetch(:offset) == start_index }
        if entity_range
          entity_key = entity_range.fetch(:key).to_s.to_sym
          entity = entity_map.fetch(entity_key)
          decorator = entity_decorators[entity.fetch(:type)]
          text = decorator.render_text(entity.fetch(:data)) if decorator && decorator.respond_to?(:render_text)
        end

        [text, commands]
      }
    end

    def build_commands(block)
      [
        Command.new(:start_text, 0),
        Command.new(:stop_text, block.fetch(:text).size)
      ] +
        build_range_commands(
          :inline_style,
          :style,
          block.fetch(:inlineStyleRanges) || []
        ) +
        build_range_commands(
          :entity,
          :key,
          block.fetch(:entityRanges) || []
        )
    end

    def build_range_commands(name, data_key, ranges)
      ranges.flat_map { |range|
        data = range.fetch(data_key)
        start = range.fetch(:offset)
        stop = start + range.fetch(:length)
        [
          Command.new("start_#{name}".to_sym, start, data),
          Command.new("stop_#{name}".to_sym, stop, data)
        ]
      }
    end

    def cdata_node(document, content)
      Nokogiri::XML::CDATA.new(
        document,
        # Escape HTML special characters. Necessary because Nokogiri doesn't
        # escape quotes but we need to for syncing to Salesforce content note.
        content
          .gsub(/&/, '&amp;')
          .gsub(/'/, '&#39;')
          .gsub(/"/, '&quot;')
          .gsub(/</, '&lt;')
          .gsub(/>/, '&gt;')
      )
    end
  end
end
