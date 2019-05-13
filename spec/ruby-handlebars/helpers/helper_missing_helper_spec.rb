require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/tree'
require_relative '../../../lib/ruby-handlebars/helpers/helper_missing_helper'


describe Handlebars::Helpers::HelperMissingHelper do
  let(:subject) { Handlebars::Helpers::HelperMissingHelper }
  let(:hbs) { Handlebars::Handlebars.new }
  let(:ctx) {Handlebars::Context.new(hbs, {})}

  it_behaves_like "a registerable helper", "helperMissing"

  context '.apply' do
    let(:name) { "missing_helper" }

    it 'raises a Handlebars::UnknownHelper exception with the name given as a parameter' do
      expect { subject.apply(ctx, name, nil, nil) }.to raise_exception(Handlebars::UnknownHelper, "Helper \"#{name}\" does not exist")
    end
  end

  context 'integration' do
    include_context "shared helpers integration tests"

    context 'is called when an unknown helper is called in a template' do
      it 'should provide a useful error message with inline helpers' do
        expect { evaluate('{{unknown "This will hardly work" }}') }.to raise_exception(Handlebars::UnknownHelper, 'Helper "unknown" does not exist')
      end

      it 'should provide a useful error message with block helpers' do
        expect { evaluate('{{#unknown}}This will hardly work{{/unknown}}') }.to raise_exception(Handlebars::UnknownHelper, 'Helper "unknown" does not exist')
      end
    end

    it 'can be overriden easily' do
      hbs.register_helper('helperMissing') do |context, name|
        # Do nothing
      end

      expect { evaluate('{{unknown "This will hardly work" }}') }.not_to raise_exception
    end
  end
end
