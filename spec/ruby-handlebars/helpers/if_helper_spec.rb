require_relative '../../spec_helper'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/if_helper'


describe Handlebars::Helpers::IfHelper do
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

  context 'integration' do
    let(:hbs) {Handlebars::Handlebars.new}

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
