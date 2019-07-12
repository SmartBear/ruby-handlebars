require_relative '../../spec_helper'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/if_helper'


describe Handlebars::Helpers::IfHelper do
  let(:subject) { Handlebars::Helpers::IfHelper }
  let(:hbs) {Handlebars::Handlebars.new}

  context '.register' do
    it 'registers the "if" helper' do
      hbs = double(Handlebars::Handlebars)
      allow(hbs).to receive(:register_helper)

      Handlebars::Helpers::IfHelper.register(hbs)

      expect(hbs)
        .to have_received(:register_helper)
        .once
        .with('if')
    end
  end

  context '.apply' do
    let (:block) { double(Handlebars::Tree::Block.new([])) }
    let(:else_block) { double(Handlebars::Tree::Block.new([])) }
    let(:condition) { true }

    before do
      allow(block).to receive(:fn)
      allow(else_block).to receive(:fn)
    end

    context 'when the block when condition is true' do
      let(:condition) { true }

      it 'applies the block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).to have_received(:fn).once
        expect(else_block).not_to have_received(:fn)
      end
    end

    context 'when the block when condition is a non empty string' do
      let(:condition) { 'something' }

      it 'applies the block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).to have_received(:fn).once
        expect(else_block).not_to have_received(:fn)
      end
    end

    context 'when the block when condition is a non-empty list' do
      let(:condition) { ['a'] }

      it 'applies the block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).to have_received(:fn).once
        expect(else_block).not_to have_received(:fn)
      end
    end

    context 'when the block when condition is a non-empty hash' do
      let(:condition) { {a: 'b'} }

      it 'applies the block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).to have_received(:fn).once
        expect(else_block).not_to have_received(:fn)
      end
    end

    context 'when the block when condition is false' do
      let(:condition) { false }

      it 'applies the else_block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end
    end

    context 'when the block when condition is an empty string' do
      let(:condition) { '' }

      it 'applies the else_block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end
    end

    context 'when the block when condition is an empty list' do
      let(:condition) { [] }

      it 'applies the else_block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end
    end

    context 'when the block when condition is an empty hash' do
      let(:condition) { {} }

      it 'applies the else_block' do
        subject.apply(hbs, condition, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end
    end
  end

  context 'integration' do
    def evaluate(template, args = {})
      hbs.compile(template).call(args)
    end

    context 'if' do
      it 'without else' do
        template = [
          "{{#if condition}}",
          "  Show something",
          "{{/if}}"
        ].join("\n")
        expect(evaluate(template, {condition: true})).to eq("\n  Show something\n")
        expect(evaluate(template, {condition: false})).to eq("")
      end

      it 'with an else' do
        template = [
          "{{#if condition}}",
          "  Show something",
          "{{ else }}",
          "  Do not show something",
          "{{/if}}"
        ].join("\n")
        expect(evaluate(template, {condition: true})).to eq("\n  Show something\n")
        expect(evaluate(template, {condition: false})).to eq("\n  Do not show something\n")
      end

      it 'imbricated ifs' do
        template = [
          "{{#if first_condition}}",
          "  {{#if second_condition}}",
          "    Case 1",
          "  {{else}}",
          "    Case 2",
          "  {{/if}}",
          "{{else}}",
          "  {{#if second_condition}}",
          "    Case 3",
          "  {{else}}",
          "    Case 4",
          "  {{/if}}",
          "{{/if}}"
        ].join("\n")

        expect(evaluate(template, {first_condition: true, second_condition: true}).strip).to eq("Case 1")
        expect(evaluate(template, {first_condition: true, second_condition: false}).strip).to eq("Case 2")
        expect(evaluate(template, {first_condition: false, second_condition: true}).strip).to eq("Case 3")
        expect(evaluate(template, {first_condition: false, second_condition: false}).strip).to eq("Case 4")
      end
    end
  end
end
