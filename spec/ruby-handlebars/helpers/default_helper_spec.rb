require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/default_helper'

describe Handlebars::Helpers::BooleanHelper do
  subject { Handlebars::Helpers::BooleanHelper }
  let(:hbs) {Handlebars::Handlebars.new}

  context '.apply' do
    it 'simply forward values to .cmp' do
      allow(subject).to receive(:cmp)
      subject.apply(hbs, 1, 2)

      expect(subject).to have_received(:cmp).once.with(1, 2)
    end

    it "returns 'true' (as a string) when cmp returns true" do
      allow(subject).to receive(:cmp).and_return(true)

      expect(subject.apply(hbs, 1, 2)).to eq('true')
    end

    it "returns an empty string when cmp returns false" do
      allow(subject).to receive(:cmp).and_return(false)

      expect(subject.apply(hbs, 1, 2)).to eq('')
    end

    it 'returns an empty string when cmp raises an exception' do
      allow(subject).to receive(:cmp).and_raise("Whatever error")

      expect(subject.apply(hbs, 1, 2)).to eq('')

    end
  end
end