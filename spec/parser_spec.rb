require_relative 'spec_helper'
require_relative '../lib/ruby-handlebars/parser'

describe Handlebars::Parser do
  let(:parser) {Handlebars::Parser.new}

  context 'recognizes' do
    it 'simple templates' do
      expect(parser.parse('Ho hi !')).to eq([{content: 'Ho hi !'}])
    end

    it 'simple replacements' do
      expect(parser.parse('{{plic}}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{ plic}}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{plic }}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{ plic }}')).to eq([{item: 'plic'}])
    end

    it 'safe strings' do
      expect(parser.parse('{{{plic}}}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{{ plic}}}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{{plic }}}')).to eq([{item: 'plic'}])
      expect(parser.parse('{{{ plic }}}')).to eq([{item: 'plic'}])
    end

    context 'helpers' do
      it 'simple' do
        expect(parser.parse('{{ capitalize plic }}')).to eq([{
          helper_name: 'capitalize',
          parameters: {parameter_name: 'plic'}
        }])
      end

      it 'with multiple parameters' do
        expect(parser.parse('{{ concat plic ploc plouf }}')).to eq([{
          helper_name: 'concat',
          parameters: [{parameter_name: 'plic'}, {parameter_name: 'ploc'}, {parameter_name: 'plouf'}]
        }])
      end

      it 'block' do
        expect(parser.parse('{{#capitalize}}plic{{/capitalize}}')).to eq([])
      end

      it 'block with parameters' do
        expect(parser.parse('{{#comment "#"}}plic{{/comment}}')).to eq([])
      end
    end

    context 'if block' do
      it 'simple' do
        expect(parser.parse('{{#if something}}show something else{{/if}}')).to eq([{
          condition: 'something',
          if_body: [{content: 'show something else'}]
        }])
      end

      it 'with an else statement' do
        expect(parser.parse('{{#if something}}Ok{{else}}not ok{{/if}}')).to eq([{
          condition: 'something',
          if_body: [{content: 'Ok'}],
          else_body: [{content: 'not ok'}]
        }])
      end

      it 'imbricated' do
        expect(parser.parse('{{#if something}}{{#if another_thing}}Plic{{/if}}ploc{{/if}}')).to eq([{
          condition: 'something',
          if_body: [{
            condition: 'another_thing',
            if_body: [{content: 'Plic'}]
          }, {content: 'ploc'}]
        }])
      end
    end

    context 'each block' do
      it 'simple' do
        expect(parser.parse('{{#each people}} {{this.name}} {{/each}}')).to eq([{
          itered_items: 'people',
          iteration_block: [{content: ' '}, {item: 'this.name'}, {content: ' '}]
        }])
      end

      it 'with naming' do
        expect(parser.parse('{{#each p in people}} {{p.name}} {{/each}}')).to eq([{
          itered_items: 'people',
          itered_item_name: 'p',
          iteration_block: [{content: ' '}, {item: 'p.name'}, {content: ' '}]
        }])
      end

      it 'imbricated' do
        expect(parser.parse('{{#each people}} {{this.name}} {{#each this.contact}} {{this}} {{/each}}{{/each}}')).to eq([{
          itered_items: 'people',
          iteration_block: [
            {content: ' '},
            {item: 'this.name'},
            {content: ' '},
            {
              itered_items: 'this.contact',
              iteration_block: [{content: ' '}, {item: 'this'}, {content: ' '}]
            }
          ]
        }])
      end
    end
  end
end
