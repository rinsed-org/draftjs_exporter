# frozen_string_literal: true
require 'spec_helper'
require 'draftjs_exporter/html'
require 'draftjs_exporter/entities/link'

RSpec.describe DraftjsExporter::HTML do
  subject(:mapper) do
    described_class.new(
      entity_decorators: {
        'LINK' => DraftjsExporter::Entities::Link.new(className: 'foobar-baz')
      },
      block_map: {
        'header-one' => { element: 'h1' },
        'ordered-list-item' => {
          element: 'li',
          wrapper: {
            element: 'ol',
            attrs: { class: 'public-DraftStyleDefault-ol' }
          }
        },
        'unordered-list-item' => {
          element: 'li',
          wrapper: {
            element: 'ul',
            attrs: { class: 'public-DraftStyleDefault-ul' }
          }
        },
        'unordered-list-item-with-multiple-wrappers' => {
          element: 'li',
          wrapper: {
            element: 'div',
            child_element: 'ul',
            attrs: { class: 'public-DraftStyleDefault-ul' }
          }
        },
        'unstyled' => { element: 'div' },
        'atomic' => [
          {
            match_data: {
              type: 'checklist',
              checked: true
            },
            options: {
              element: 'span',
              attrs: { id: 'hello-world' }
            }
          },
          {
            match_data: {
              type: 'story',
              name: 'yvonne'
            },
            options: {
              element: 'article',
              attrs: { title: 'paradise' },
              prefix: '( ) '
            }
          }
        ]
      },
      style_map: {
        'ITALIC' => { fontStyle: 'italic' }
      },
      style_block_map: {
        'ITALIC' => 'i',
        'BOLD' => 'b',
        'UNDERLINE' => 'u',
        'STRIKETHROUGH' => 's'
      }
    )
  end

  describe '#call' do
    context 'with different blocks' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: '5s7g9',
              text: 'Header',
              type: 'header-one',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: '5s7g9',
              text: 'some random stuff',
              type: 'star-wars',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem5p',
              text: 'Name: Diana G',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: '6udia',
              text: 'Hello my beautiful children',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {
                type: 'checklist',
                checked: true
              }
            },
            {
              key: '7j1l',
              text: 'Nice to meet me',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {
                type: 'story',
                name: 'yvonne'
              }
            },
            {
              key: 'jq89x',
              text: 'Wishful thinking',
              type: 'atomic',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: { type: 'task' }
            },
          ]
        }

        expected_output = <<-OUTPUT.strip
<h1>\nHeader\n</h1><div>\nsome random stuff\n</div><div>\nName: Diana G\n</div><span id="hello-world">Hello my beautiful children</span><article title="paradise">( ) Nice to meet me</article><div>\nWishful thinking\n</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end

    context 'with inline styles' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [
                {
                  offset: 0,
                  length: 4,
                  style: 'ITALIC'
                },
                {
                  offset: 0,
                  length: 4,
                  style: 'UNDERLINE'
                },
                {
                  offset: 0,
                  length: 4,
                  style: 'STRIKETHROUGH'
                },
                {
                  offset: 1,
                  length: 3,
                  style: 'BOLD'
                },
                {
                  offset: 5,
                  length: 5,
                  style: 'BOLD'
                }
              ],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>\n<i><u><s><span style=\"font-style: italic;\">s</span></s></u></i><i><b><u><s><span style=\"font-style: italic;\">ome</span></s></u></b></i> <b>parag</b>raph text\n</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end

    context 'with entities' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {
            '0' => {
              type: 'LINK',
              mutability: 'MUTABLE',
              data: {
                url: 'http://example.com'
              }
            },
            '1' => {
              type: 'ALIEN',
              mutability: 'MUTABLE',
              data: {
                gender: 'male'
              }
            }
          },
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                }
              ]
            },
            {
              key: 'ay89q',
              text: 'some random stuff',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 1
                }
              ]
            },
          ]
        }

        expected_output = <<-OUTPUT.strip
<div>\nsome <a href=\"http://example.com\" class=\"foobar-baz\">paragraph</a> text\n</div><div>\nsome random stuff\n</div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end

      context 'with deeply_symbolized entities' do
        it 'decodes the content_state to html' do
          input = {
            entityMap: {
              :'0' => {
                type: 'LINK',
                mutability: 'MUTABLE',
                data: {
                  url: 'http://example.com'
                }
              }
            },
            blocks: [
              {
                key: 'dem5p',
                text: 'some paragraph text',
                type: 'unstyled',
                depth: 0,
                inlineStyleRanges: [],
                entityRanges: [
                  {
                    offset: 5,
                    length: 9,
                    key: 0
                  }
                ]
              }
            ]
          }

          expected_output = <<-OUTPUT.strip
<div>\nsome <a href="http://example.com" class="foobar-baz">paragraph</a> text\n</div>
          OUTPUT

          expect(mapper.call(input)).to eq(expected_output)
        end
      end


      it 'throws an error if entities cross over' do
        input = {
          entityMap: {
            '0' => {
              type: 'LINK',
              mutability: 'MUTABLE',
              data: {
                url: 'http://foo.example.com'
              }
            },
            '1' => {
              type: 'LINK',
              mutability: 'MUTABLE',
              data: {
                url: 'http://bar.example.com'
              }
            }
          },
          blocks: [
            {
              key: 'dem5p',
              text: 'some paragraph text',
              type: 'unstyled',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [
                {
                  offset: 5,
                  length: 9,
                  key: 0
                },
                {
                  offset: 2,
                  length: 9,
                  key: 1
                }
              ]
            }
          ]
        }

        expect { mapper.call(input) }.to raise_error(DraftjsExporter::InvalidEntity)
      end
    end

    context 'with wrapped blocks' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'dem5p',
              text: 'item1',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem5p',
              text: 'item2',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<ul class="public-DraftStyleDefault-ul">\n<li>\nitem1\n</li>\n<li>\nitem2\n</li>\n</ul>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end

    context 'with multiple wrapping elements' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'dem5p',
              text: 'item1',
              type: 'unordered-list-item-with-multiple-wrappers',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem5p',
              text: 'item2',
              type: 'unordered-list-item-with-multiple-wrappers',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
<div class="public-DraftStyleDefault-ul"><ul>\n<li>\nitem1\n</li>\n<li>\nitem2\n</li>\n</ul></div>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end

    context 'with nested blocks' do
      it 'decodes the content_state to html' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'dem5p',
              text: 'item1',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem6p',
              text: 'item2',
              type: 'unordered-list-item',
              depth: 1,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem7p',
              text: 'item3',
              type: 'unordered-list-item',
              depth: 1,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem8p',
              text: 'item4',
              type: 'unordered-list-item',
              depth: 2,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem9p',
              text: 'item5',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem0p',
              text: 'item6',
              type: 'unordered-list-item',
              depth: 2,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem1p',
              text: 'item7',
              type: 'unordered-list-item',
              depth: 1,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem2p',
              text: 'item8',
              type: 'unordered-list-item',
              depth: 5,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem3p',
              text: 'item9',
              type: 'ordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: 'dem4p',
              text: 'item10',
              type: 'unordered-list-item',
              depth: 3,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: "6a082",
              text: "item11",
              type: "unstyled",
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: '6a083',
              text: 'item12',
              type: 'ordered-list-item',
              depth: 3,
              inlineStyleRanges: [],
              entityRanges: []
            },
            {
              key: '6a084',
              text: 'item13',
              type: 'ordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: []
            },
          ]
        }

        expected_output = <<-OUTPUT.strip
          <ul class=\"public-DraftStyleDefault-ul\">\n<li>\nitem1<ul class=\"public-DraftStyleDefault-ul\">\n<li>\nitem2\n</li>\n<li>\nitem3<ul class=\"public-DraftStyleDefault-ul\"><li>\nitem4\n</li></ul>\n</li>\n</ul>\n</li>\n<li>\nitem5<ul class=\"public-DraftStyleDefault-ul\">\n<li>\nitem6\n</li>\n<li>\nitem7<ul class=\"public-DraftStyleDefault-ul\"><li>\nitem8\n</li></ul>\n</li>\n</ul>\n</li>\n</ul><ol class=\"public-DraftStyleDefault-ol\"><li>\nitem9<ul class=\"public-DraftStyleDefault-ul\"><li>\nitem10\n</li></ul>\n</li></ol><div>\nitem11\n</div><ol class=\"public-DraftStyleDefault-ol\">\n<li>\nitem12\n</li>\n<li>\nitem13\n</li>\n</ol>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end

    context 'with UTF-8 encoding' do
      it 'leaves non-latin letters as-is' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'ckf8d',
              text: 'Russian: Привет, мир!',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            },
            {
              key: 'fi809',
              text: 'Japanese: 曖昧さ回避',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
          <ul class=\"public-DraftStyleDefault-ul\">\n<li>\nRussian: Привет, мир!\n</li>\n<li>\nJapanese: 曖昧さ回避\n</li>\n</ul>
        OUTPUT

        expect(mapper.call(input, encoding: 'UTF-8')).to eq(expected_output)
      end
    end

    context 'with HTML special characters' do
      it 'escapes those characters' do
        input = {
          entityMap: {},
          blocks: [
            {
              key: 'ckf8d',
              text: '<> Hey &',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            },
            {
              key: 'fi809',
              text: '\' Foo \' "Bar" ',
              type: 'unordered-list-item',
              depth: 0,
              inlineStyleRanges: [],
              entityRanges: [],
              data: {}
            }
          ]
        }

        expected_output = <<-OUTPUT.strip
          <ul class=\"public-DraftStyleDefault-ul\">\n<li>\n&lt;&gt; Hey &amp;\n</li>\n<li>\n&#39; Foo &#39; &quot;Bar&quot; \n</li>\n</ul>
        OUTPUT

        expect(mapper.call(input)).to eq(expected_output)
      end
    end
  end
end
