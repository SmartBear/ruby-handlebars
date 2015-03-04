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
        expect(parser.parse('{{#capitalize}}plic{{/capitalize}}')).to eq([{
          helper_name: 'capitalize',
          helper_block: [{content: 'plic'}]
        }])
      end

      it 'block with parameters' do
        expect(parser.parse('{{#comment "#"}}plic{{/comment}}')).to eq([{
          helper_name: 'comment',
          parameters: {parameter_name: {content: '#'}},
          helper_block: [{content: 'plic'}]
        }])
      end
    end

    context 'if block' do
      it 'simple' do
        expect(parser.parse('{{#if something}}show something else{{/if}}')).to eq([{
          helper_name: 'if',
          parameters: {parameter_name: 'something'},
          helper_block: [{content: 'show something else'}]
        }])
      end

      it 'with an else statement' do
        expect(parser.parse('{{#if something}}Ok{{else}}not ok{{/if}}')).to eq([{
          helper_name: 'if',
          parameters: {parameter_name: 'something'},
          helper_block: [{content: 'Ok'}, {item: 'else'}, {content: 'not ok'}]
        }])
      end

      it 'imbricated' do
        expect(parser.parse('{{#if something}}{{#if another_thing}}Plic{{/if}}ploc{{/if}}')).to eq([{
          helper_name: 'if',
          parameters: {parameter_name: 'something'},
          helper_block: [{
            helper_name: 'if',
            parameters: {parameter_name: 'another_thing'},
            helper_block: [{content: 'Plic'}]
          }, {content: 'ploc'}]
        }])
      end
    end

    context 'each block' do
      it 'simple' do
        expect(parser.parse('{{#each people}} {{this.name}} {{/each}}')).to eq([{
          helper_name: 'each',
          parameters: {parameter_name: 'people'},
          helper_block: [{content: ' '}, {item: 'this.name'}, {content: ' '}]
        }])
      end

      it 'with naming' do
        expect(parser.parse('{{#each p in people}} {{p.name}} {{/each}}')).to eq([{
          helper_name: 'each',
          parameters: [{parameter_name: 'p'}, {parameter_name: 'in'}, {parameter_name: 'people'}],
          helper_block: [{content: ' '}, {item: 'p.name'}, {content: ' '}]
        }])
      end

      it 'imbricated' do
        expect(parser.parse('{{#each people}} {{this.name}} <ul> {{#each this.contact}} <li>{{this}}</li> {{/each}}</ul>{{/each}}')).to eq([{
          helper_name: 'each',
          parameters: {parameter_name: 'people'},
          helper_block: [
            {content: ' '},
            {item: 'this.name'},
            {content: ' <ul> '},
            {
              helper_name: 'each',
              parameters: {parameter_name: 'this.contact'},
              helper_block: [{content: ' <li>'}, {item: 'this'}, {content: '</li> '}]
            },
            {content: '</ul>'}
          ]
        }])
      end
    end
  end
end
