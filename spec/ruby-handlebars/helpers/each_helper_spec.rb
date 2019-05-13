require_relative '../../spec_helper'
require_relative './shared'

require_relative '../../../lib/ruby-handlebars'
require_relative '../../../lib/ruby-handlebars/tree'
require_relative '../../../lib/ruby-handlebars/helpers/each_helper'


describe Handlebars::Helpers::EachHelper do
  let(:subject) { Handlebars::Helpers::EachHelper }
  let(:hbs) {Handlebars::Handlebars.new}
  let(:ctx) {Handlebars::Context.new(hbs, {})}

  it_behaves_like "a registerable helper", "each"

  context '.apply' do
    include_context "shared apply helper"

    let(:values) { [Handlebars::Tree::String.new('a'), Handlebars::Tree::String.new('b'), Handlebars::Tree::String.new('c') ]}

    it 'applies the block on all values' do
      subject.apply(ctx, values, block, else_block)

      expect(block).to have_received(:fn).exactly(3).times
      expect(else_block).not_to have_received(:fn)
    end

    context 'when values is nil' do
      let(:values) { nil }

      it 'uses the else_block if provided' do
        subject.apply(ctx, values, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end

      it 'returns nil if no else_block is provided' do
        expect(subject.apply(ctx, values, block, nil)).to be nil
      end
    end

    context 'when values is empty' do
      let(:values) { [] }

      it 'uses the else_block if provided' do
        subject.apply(ctx, values, block, else_block)

        expect(block).not_to have_received(:fn)
        expect(else_block).to have_received(:fn).once
      end

      it 'returns nil if no else_block is provided' do
        expect(subject.apply(ctx, values, block, nil)).to be nil
      end
    end
  end

  context 'integration' do
    include_context "shared helpers integration tests"

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

  context 'integration with "as |value|" notation' do
    include_context "shared helpers integration tests"

    let(:ducks) {[{name: 'Huey'}, {name: 'Dewey'}, {name: 'Louis'}]}

    it 'simple case' do
      template = [
        "<ul>",
        "{{#each items as |item|}}  <li>{{item.name}}</li>",
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
        "  {{#each people as |person| }}",
        "  <li>",
        "    <ul>",
        "      <li>Name: {{person.name}}</li>",
        "      <li>Phones: {{#each person.phones as |phone|}} {{phone}} {{/each}}</li>",
        "      <li>email: {{person.email}}</li>",
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
  end
end
