require_relative 'spec_helper'
require_relative '../lib/ruby-handlebars/parser'

describe Handlebars::Parser do
  let(:parser) {Handlebars::Parser.new}

  context 'recognizes' do
    it 'simple templates' do
      expect(parser.parse('Ho hi !')).to eq({
        block_items: [
          {template_content: 'Ho hi !'}
        ]
      })
    end

    it 'simple replacements' do
      expect(parser.parse('{{plic}}')).to eq({
        block_items: [
          {replaced_unsafe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{ plic}}')).to eq({
        block_items: [
          {replaced_unsafe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{plic }}')).to eq({
        block_items: [
          {replaced_unsafe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{ plic }}')).to eq({
        block_items: [
          {replaced_unsafe_item: 'plic'}
        ]
      })
    end

    it 'special variables' do
      expect(parser.parse('{{@first}}')).to eq({
        block_items: [
          {replaced_unsafe_item: '@first'}
        ]
      })
      expect(parser.parse('{{@last}}')).to eq({
        block_items: [
          {replaced_unsafe_item: '@last'}
        ]
      })
      expect(parser.parse('{{@index}}')).to eq({
        block_items: [
          {replaced_unsafe_item: '@index'}
        ]
      })
    end

    it 'safe strings' do
      expect(parser.parse('{{{plic}}}')).to eq({
        block_items: [
          {replaced_safe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{{ plic}}}')).to eq({
        block_items: [
          {replaced_safe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{{plic }}}')).to eq({
        block_items: [
          {replaced_safe_item: 'plic'}
        ]
      })

      expect(parser.parse('{{{ plic }}}')).to eq({
        block_items: [
          {replaced_safe_item: 'plic'}
        ]
      })

    end

    context 'helpers' do
      it 'simple' do
        expect(parser.parse('{{ capitalize plic }}')).to eq({
          block_items: [
            {
              unsafe_helper_name: 'capitalize',
              parameters: {parameter_name: 'plic'}
            }
          ]
        })
      end

      it 'with single-quoted string parameter' do
        expect(parser.parse("{{ capitalize 'hi'}}")).to eq({
          block_items: [
            {
              unsafe_helper_name: 'capitalize',
              parameters: {parameter_name: {str_content: 'hi'}},
            }
          ]
        })
      end

      it 'with single-quoted empty string parameter' do
        expect(parser.parse("{{ capitalize ''}}")).to eq({
          block_items: [
            {
              unsafe_helper_name: 'capitalize',
              parameters: {parameter_name: {str_content: ''}},
            }
          ]
        })
      end

      it 'with double-quoted string parameter' do
        expect(parser.parse('{{ capitalize "hi"}}')).to eq({
          block_items: [
            {
              unsafe_helper_name: 'capitalize',
              parameters: {parameter_name: {str_content: 'hi'}},
            }
          ]
        })
      end

      it 'with double-quoted empty string parameter' do
        expect(parser.parse('{{ capitalize ""}}')).to eq({
          block_items: [
            {
              unsafe_helper_name: 'capitalize',
              parameters: {parameter_name: {str_content: ''}},
            }
          ]
        })
      end

      it 'with multiple parameters' do
        expect(parser.parse('{{ concat plic ploc plouf }}')).to eq({
          block_items: [
            {
              unsafe_helper_name: 'concat',
              parameters: [
                {parameter_name: 'plic'},
                {parameter_name: 'ploc'},
                {parameter_name: 'plouf'}
              ]
            }
          ]
        })
      end

      it 'block' do
        expect(parser.parse('{{#capitalize}}plic{{/capitalize}}')).to eq({
          block_items: [
            {
              helper_name: 'capitalize',
              block_items: [
                {template_content: 'plic'}
              ]
            }
          ]
        })
      end

      it 'block with parameters' do
        expect(parser.parse('{{#comment "#"}}plic{{/comment}}')).to eq({
          block_items: [
            {
              helper_name: 'comment',
              parameters: {parameter_name: {str_content: '#'}},
              block_items: [
                {template_content: 'plic'}
              ]
            }
          ]
        })
      end

      it 'imbricated blocks' do
        expect(parser.parse('{{#comment "#"}}plic {{#capitalize}}ploc{{/capitalize}} plouc{{/comment}}')).to eq({
          block_items: [
            {
              helper_name: 'comment',
              parameters: {parameter_name: {str_content: '#'}},
              block_items: [
                {template_content: 'plic '},
                {
                  helper_name: 'capitalize',
                  block_items: [{template_content: 'ploc'}]
                },
                {template_content: ' plouc'},
              ]
            }
          ]
        })
      end

      it 'helpers as arguments' do
        expect(parser.parse('{{foo (bar baz)}}')).to eq({
          block_items: [
            {
              unsafe_helper_name: 'foo',
              parameters: {
                safe_helper_name: 'bar',
                parameters: {parameter_name: 'baz'}
              }
            }
          ]
        })
      end
    end

    context 'as helpers' do
      it 'recognizes the "as |...|" writing' do
        expect(parser.parse('{{#each items as |item|}}plic{{/each}}')).to eq({
          block_items: [
            {
              helper_name: 'each',
              parameters: {parameter_name: 'items'},
              as_parameters: {parameter_name: 'item'},
              block_items: [
                {template_content: 'plic'}
              ]
            }
          ]
        })
      end

      it 'supports the "else" statement' do
        expect(parser.parse('{{#each items as |item|}}plic{{else}}Hummm, empty{{/each}}')).to eq({
          block_items: [
            {
              helper_name: 'each',
              parameters: {parameter_name: 'items'},
              as_parameters: {parameter_name: 'item'},
              block_items: [
                {template_content: 'plic'}
              ],
              else_block_items: [
                {template_content: 'Hummm, empty'}
              ]
            }
          ]
        })
      end

      it 'can be imbricated' do
        expect(parser.parse('{{#each items as |item|}}{{#each item as |char index|}}show item{{/each}}{{else}}Hummm, empty{{/each}}')).to eq({
          block_items: [
            {
              helper_name: 'each',
              parameters: {parameter_name: 'items'},
              as_parameters: {parameter_name: 'item'},
              block_items: [
                {
                  helper_name: 'each',
                  parameters: {parameter_name: 'item'},
                  as_parameters: [
                    {parameter_name: 'char'},
                    {parameter_name: 'index'}],
                  block_items: [
                    {template_content: 'show item'}
                  ]
                }
              ],
              else_block_items: [
                {template_content: 'Hummm, empty'}
              ]
            }
          ]
        })
      end
    end

    context 'if block' do
      it 'simple' do
        expect(parser.parse('{{#if something}}show something else{{/if}}')).to eq({
          block_items: [
            {
              helper_name: 'if',
              parameters: {parameter_name: 'something'},
              block_items: [
                {template_content: 'show something else'}
              ]
            }
          ]
        })
      end

      it 'with an else statement' do
        expect(parser.parse('{{#if something}}Ok{{else}}not ok{{/if}}')).to eq({
          block_items: [
            {
              helper_name: 'if',
              parameters: {parameter_name: 'something'},
              block_items: [
                {template_content: 'Ok'}
              ],
              else_block_items: [
                {template_content: 'not ok'}
              ]
            }
          ]
        })
      end

      it 'imbricated' do
        expect(parser.parse('{{#if something}}{{#if another_thing}}Plic{{/if}}ploc{{/if}}')).to eq({
          block_items: [
            {
              helper_name: 'if',
              parameters: {parameter_name: 'something'},
              block_items: [
                {
                  helper_name: 'if',
                  parameters: {parameter_name: 'another_thing'},
                  block_items: [
                    {template_content: 'Plic'}
                  ]
                },
                {template_content: 'ploc'}
              ]
            }
          ]
        })
      end

      it 'imbricated block with elses' do
        expect(parser.parse('{{#if something}}{{#if another_thing}}Case 1{{else}}Case 2{{/if}}{{else}}{{#if another_thing}}Case 3{{else}}Case 4{{/if}}{{/if}}')).to eq({
          block_items: [
            {
              helper_name: "if",
              parameters: {parameter_name: "something"},
              block_items: [
                {
                  helper_name: "if",
                  parameters: {parameter_name: "another_thing"},
                  block_items:[
                    {
                      template_content:"Case 1"
                    }
                  ],
                  else_block_items: [
                    {
                      template_content: "Case 2"
                    }
                  ]
                }
              ],
              else_block_items: [
                {
                  helper_name: "if",
                  parameters: {parameter_name: "another_thing"},
                  block_items:[
                    {
                      template_content:"Case 3"
                    }
                  ],
                  else_block_items: [
                    {
                      template_content: "Case 4"
                    }
                  ]
                }
              ]
            }
          ]
        })
      end
    end

    context 'each block' do
      it 'simple' do
        expect(parser.parse('{{#each people}} {{this.name}} {{/each}}')).to eq({
          block_items: [
            {
              helper_name: 'each',
              parameters: {parameter_name: 'people'},
              block_items: [
                {template_content: ' '},
                {replaced_unsafe_item: 'this.name'},
                {template_content: ' '}
              ]
            }
          ]
        })
      end

      it 'imbricated' do
        expect(parser.parse('{{#each people}} {{this.name}} <ul> {{#each this.contact}} <li>{{this}}</li> {{/each}}</ul>{{/each}}')).to eq({
          block_items: [
            {
              helper_name: 'each',
              parameters: {parameter_name: 'people'},
              block_items: [
                {template_content: ' '},
                {replaced_unsafe_item: 'this.name'},
                {template_content: ' <ul> '},
                {
                  helper_name: 'each',
                  parameters: {parameter_name: 'this.contact'},
                  block_items: [
                    {template_content: ' <li>'},
                    {replaced_unsafe_item: 'this'},
                    {template_content: '</li> '}
                  ]
                },
                {template_content: '</ul>'}
              ]
            }
          ]
        })
      end
    end

    context 'templates with single curlies' do
      it 'works with loose curlies' do
        expect(parser.parse('} Hi { hey } {')).to eq({
          block_items: [
            {template_content: '} Hi { hey } {'}
          ]
        })
      end

      it 'works with groups of curlies' do
        expect(parser.parse('{ Hi }{ hey }')).to eq({
          block_items: [
            {template_content: '{ Hi }{ hey }'}
          ]
        })
      end

      it 'works with closing curly before value' do
        expect(parser.parse('Hi }{{ hey }}')).to eq({
          block_items: [
            {template_content: 'Hi }'},
            {replaced_unsafe_item: 'hey'}
          ]
        })
      end

      it 'works with closing curly before value at the start' do
        expect(parser.parse('}{{ hey }}')).to eq({
          block_items: [
            {template_content: '}'},
            {replaced_unsafe_item: 'hey'}
          ]
        })
      end
    end
  end
end
