require_relative '../../spec_helper'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/register_default_helpers'


describe Handlebars::Helpers do
  context '.register_default_helpers' do
    it 'registers the default helpers' do
      hbs = double(Handlebars::Handlebars)
      allow(hbs).to receive(:register_helper)
      allow(hbs).to receive(:register_as_helper)


      Handlebars::Helpers.register_default_helpers(hbs)

      expect(hbs)
        .to have_received(:register_helper)
        .once
        .with('if')
        .once
        .with('unless')
        .once
        .with('each')
        .once
        .with('helperMissing')

      expect(hbs)
        .to have_received(:register_as_helper)
        .once
        .with('each')
    end
  end
end
