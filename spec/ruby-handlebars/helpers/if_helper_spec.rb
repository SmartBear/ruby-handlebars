require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/if_helper'


describe Handlebars::Helpers::IfHelper do
  let(:subject) { Handlebars::Helpers::IfHelper }
  let(:hbs) {Handlebars::Handlebars.new}

  it_behaves_like "a registerable helper", "if"

  context '.apply' do
    it_behaves_like "a helper running the main block", 'true', true
    it_behaves_like "a helper running the main block", 'a non-empty string', 'something'
    it_behaves_like "a helper running the main block", 'a non-empty list', ['a']
    it_behaves_like "a helper running the main block", 'a non-empty hash', {a: 'b'}

    it_behaves_like "a helper running the else block", "false", false
    it_behaves_like "a helper running the else block", "an empty string", ""
    it_behaves_like "a helper running the else block", "an empty list", []
    it_behaves_like "a helper running the else block", "an empty hash", {}

    context 'when else_block is not present' do
      include_context "shared apply helper"
      let(:params) { false }
      let(:else_block) { nil }

      it 'returns an empty-string' do
        expect(subject.apply(hbs, params, block, else_block)).to eq("")

        expect(block).not_to have_received(:fn)
        expect(else_block).not_to have_received(:fn)
      end
    end
  end

  context 'integration' do
    include_context "shared helpers integration tests"

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
