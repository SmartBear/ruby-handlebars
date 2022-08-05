require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars/helpers/gte_helper'


describe Handlebars::Helpers::GteHelper do
  let(:subject) { Handlebars::Helpers::GteHelper }
  let(:hbs) {Handlebars::Handlebars.new}

  it_behaves_like "a registerable helper", "gte"

  context '.apply' do
    include_context "shared apply helper"

    it 'returns "true" when first value is greater or equal than second one' do
      expect(subject.apply(hbs, 1, 1)).to eq('true')
    end

    it 'returns an empty string when first value is greater or equal than second one' do
      expect(subject.apply(hbs, 1, 2)).to eq('')
    end

    it 'returns an empty string when values can not be compared' do
      expect(subject.apply(hbs, 123, "456")).to eq('')
    end

    it 'not not takes the blocks into account' do
      subject.apply(hbs, 123, 123, block, else_block)
      subject.apply(hbs, 123, 456, block, else_block)

      expect(block).not_to have_received(:fn)
      expect(else_block).not_to have_received(:fn)
    end
  end

  context 'integration' do
    include_context "shared helpers integration tests"

    it 'can be used as a condition for an #if helper' do
      template = "{{#if (gt a b)}}Ok{{else}}Not ok ...{{/if}}"

      expect(evaluate(template, {a: 2, b: 1})).to eq("Ok")
      expect(evaluate(template, {a: 0, b: 1})).to eq("Not ok ...")
    end
  end
end