require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/tree'
require_relative '../../../lib/ruby-handlebars/helpers/with_helper'

describe Handlebars::Helpers::WithHelper do
  let(:subject) { Handlebars::Helpers::WithHelper }
  let(:hbs) { Handlebars::Handlebars.new }

  it_behaves_like "a registerable helper", "with"

  context '.apply' do
    include_context "shared apply helper"
  end

  context "integration" do
    include_context "shared helpers integration tests"

    let(:person_data) { { person: { firstname: "Yehuda", lastname: "Katz" }} }
    let(:city_data) { {
      city: {
        name: "San Francisco",
        summary: "San Francisco is the <b>cultural center</b> of <b>Northern California</b>",
        location: {
          north: "37.73,",
          east: -122.44,
        },
        population: 883305,
      },
    } }

    it "changes the evaluation context" do
      template = <<~HANDLEBARS
        {{#with person}}
        {{firstname}} {{lastname}}
        {{/with}}
      HANDLEBARS

      expect(evaluate(template, person_data).strip).to eq("Yehuda Katz")
    end

    it "supports block parameters" do
      template = <<~HANDLEBARS
        {{#with city as | city |}}
          {{#with city.location as | loc |}}
            {{city.name}}: {{loc.north}} {{loc.east}}
          {{/with}}
        {{/with}}
      HANDLEBARS

      expect(evaluate(template, city_data).strip).to eq("San Francisco: 37.73, -122.44")
    end

    it "supports else blocks" do
      template = <<~HANDLEBARS
        {{#with city}}
        {{city.name}} (not shown because there is no city)
        {{else}}
        No city found
        {{/with}}
      HANDLEBARS

      expect(evaluate(template, person_data).strip).to eq("No city found")
    end

    it "supports relative paths", skip: "Relative paths are not yet supported" do
      template = <<~HANDLEBARS
        {{#with city as | city |}}
          {{#with city.location as | loc |}}
            {{city.name}}: {{../population}}
          {{/with}}
        {{/with}}
      HANDLEBARS

      expect(evaluate(template, city_data).strip).to eq("San Francisco: 883305")
    end
  end
end
