require_relative '../../spec_helper'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/helpers/each_helper'


describe Handlebars::Helpers::EachHelper do
  context '.register' do
    it 'registers the "each" helper' do
      hbs = double(Handlebars::Handlebars)
      allow(hbs).to receive(:register_helper)

      Handlebars::Helpers::EachHelper.register(hbs)

      expect(hbs)
        .to have_received(:register_helper)
        .once
        .with('each')
    end
  end

  context 'integration' do
    let(:hbs) {Handlebars::Handlebars.new}

    def evaluate(template, args = {})
      hbs.compile(template).call(args)
    end

    let(:ducks) {[{name: 'Huey'}, {name: 'Dewey'}, {name: 'Louis'}]}

    it 'simple case' do
      template = [
        "<ul>",
        "{{#each items}}  <li>{{this.name}}</li>",
        "{{/each}}</ul>"
      ].join("\n")

      data = {items: ducks}
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "  <li>Huey</li>",
        "  <li>Dewey</li>",
        "  <li>Louis</li>",
        "</ul>"
      ].join("\n"))

      data = {items: []}
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "</ul>"
      ].join("\n"))
    end

    it 'considers not found items as an empty list and does not raise an error' do
      template = [
        "<ul>",
        "{{#each stuff}}  <li>{{this.name}}</li>",
        "{{/each}}</ul>"
      ].join("\n")

      expect(evaluate(template, {})).to eq([
        "<ul>",
        "</ul>"
      ].join("\n"))
    end

    it 'considers not found items as an empty list and uses else block if provided' do
      template = [
        "<ul>",
        "{{#each stuff}}  <li>{{this.name}}</li>",
        "{{else}}  <li>No stuff found....</li>",
        "{{/each}}</ul>"
      ].join("\n")

      expect(evaluate(template, {})).to eq([
        "<ul>",
        "  <li>No stuff found....</li>",
        "</ul>"
      ].join("\n"))
    end

    it 'works with non-hash data' do
      template = [
        "<ul>",
        "{{#each items}}  <li>{{this.name}}</li>",
        "{{/each}}</ul>"
      ].join("\n")

      data = double(items: ducks)
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "  <li>Huey</li>",
        "  <li>Dewey</li>",
        "  <li>Louis</li>",
        "</ul>"
      ].join("\n"))

      data = {items: []}
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "</ul>"
      ].join("\n"))
    end

    it 'using an else statement' do
      template = [
        "<ul>",
        "{{#each items}}  <li>{{this.name}}</li>",
        "{{else}}  <li>No ducks to display</li>",
        "{{/each}}</ul>"
      ].join("\n")

      data = {items: ducks}
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "  <li>Huey</li>",
        "  <li>Dewey</li>",
        "  <li>Louis</li>",
        "</ul>"
      ].join("\n"))

      data = {items: []}
      expect(evaluate(template, data)).to eq([
        "<ul>",
        "  <li>No ducks to display</li>",
        "</ul>"
      ].join("\n"))
    end

    it 'imbricated' do
      data = {people: [
        {
          name: 'Huey',
          email: 'huey@junior-woodchucks.example.com',
          phones: ['1234', '5678'],
        },
        {
          name: 'Dewey',
          email: 'dewey@junior-woodchucks.example.com',
          phones: ['4321'],
        }
      ]}

      template = [
        "People:",
        "<ul>",
        "  {{#each people}}",
        "  <li>",
        "    <ul>",
        "      <li>Name: {{this.name}}</li>",
        "      <li>Phones: {{#each this.phones}} {{this}} {{/each}}</li>",
        "      <li>email: {{this.email}}</li>",
        "    </ul>",
        "  </li>",
        "  {{else}}",
        "  <li>No one to display</li>",
        "  {{/each}}",
        "</ul>"
      ].join("\n")

      expect(evaluate(template, data)).to eq([
        "People:",
        "<ul>",
        "  ",
        "  <li>",
        "    <ul>",
        "      <li>Name: Huey</li>",
        "      <li>Phones:  1234  5678 </li>",
        "      <li>email: huey@junior-woodchucks.example.com</li>",
        "    </ul>",
        "  </li>",
        "  ",
        "  <li>",
        "    <ul>",
        "      <li>Name: Dewey</li>",
        "      <li>Phones:  4321 </li>",
        "      <li>email: dewey@junior-woodchucks.example.com</li>",
        "    </ul>",
        "  </li>",
        "  ",
        "</ul>"
      ].join("\n"))
    end

    context 'special variables' do
      it '@first' do
        template = [
          "{{#each items}}",
          "{{this}}",
          "{{#if @first}}",
          " first",
          "{{/if}}\n",
          "{{/each}}"
        ].join
        expect(evaluate(template, {items: %w(a b c)})).to eq("a first\nb\nc\n")
      end

      it '@last' do
        template = [
          "{{#each items}}",
          "{{this}}",
          "{{#if @last}}",
          " last",
          "{{/if}}\n",
          "{{/each}}"
        ].join
        expect(evaluate(template, {items: %w(a b c)})).to eq("a\nb\nc last\n")
      end

      it '@index' do
        template = [
          "{{#each items}}",
          "{{this}} {{@index}}\n",
          "{{/each}}"
        ].join
        expect(evaluate(template, {items: %w(a b c)})).to eq("a 0\nb 1\nc 2\n")
      end
    end
  end
end
