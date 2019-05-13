require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/unless_helper'


describe Handlebars::Helpers::UnlessHelper do
  let(:subject) { Handlebars::Helpers::UnlessHelper }
  let(:hbs) {Handlebars::Handlebars.new}
  let(:ctx) {Handlebars::Context.new(hbs, {})}

  it_behaves_like "a registerable helper", "unless"

  context '.apply' do
    it_behaves_like "a helper running the main block", "false", false
    it_behaves_like "a helper running the main block", "an empty string", ""
    it_behaves_like "a helper running the main block", "an empty list", []
    it_behaves_like "a helper running the main block", "an empty hash", {}

    it_behaves_like "a helper running the else block", 'true', true
    it_behaves_like "a helper running the else block", 'a non-empty string', 'something'
    it_behaves_like "a helper running the else block", 'a non-empty list', ['a']
    it_behaves_like "a helper running the else block", 'a non-empty hash', {a: 'b'}

    context 'when else_block is not present' do
      include_context "shared apply helper"
      let(:params) { true }
      let(:else_block) { nil }

      it 'returns an empty-string' do
        expect(subject.apply(ctx, params, block, else_block)).to eq("")

        expect(block).not_to have_received(:fn)
        expect(else_block).not_to have_received(:fn)
      end
    end
  end

  context 'integration' do
    include_context "shared helpers integration tests"

    it 'without else' do
      template = [
        "{{#unless condition}}",
        "  Show something",
        "{{/unless}}"
      ].join("\n")
      expect(evaluate(template, {condition: false})).to eq("\n  Show something\n")
      expect(evaluate(template, {condition: true})).to eq("")
    end

    it 'with an else' do
      template = [
        "{{#unless condition}}",
        "  Show something",
        "{{ else }}",
        "  Do not show something",
        "{{/unless}}"
      ].join("\n")
      expect(evaluate(template, {condition: false})).to eq("\n  Show something\n")
      expect(evaluate(template, {condition: true})).to eq("\n  Do not show something\n")
    end
  end
end
