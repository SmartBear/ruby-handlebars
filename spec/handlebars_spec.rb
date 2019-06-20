require_relative 'spec_helper'
require_relative '../lib/ruby-handlebars'

describe Handlebars::Handlebars do
  let(:hbs) {Handlebars::Handlebars.new}

  def evaluate(template, args = {})
    hbs.compile(template).call(args)
  end

  context 'evaluating' do
    it 'a dummy template' do
      expect(evaluate('My simple template')).to eq('My simple template')
    end

    it 'a simple replacement' do
      expect(evaluate('Hello {{name}}', {name: 'world'})).to eq('Hello world')
    end

    it 'allows values specified by methods' do
      expect(evaluate('Hello {{name}}', double(name: 'world'))).to eq('Hello world')
    end

    it 'prefers hash value over method value' do
      expect(evaluate('Hello {{name}}', double(name: 'world', '[]': 'dog', has_key?: true))).to eq('Hello dog')
    end

    it 'handles object that implement #[] but not #has_key?' do
      expect(evaluate('Hello {{name}}', double(name: 'world', '[]': 'dog'))).to eq('Hello world')
    end

    it 'a replacement with a path' do
      expect(evaluate('My simple template: {{person.name}}', {person: {name: 'Another name'}})).to eq('My simple template: Another name')
    end

    context 'partials' do
      it 'simple' do
        hbs.register_partial('plic', "Plic")
        expect(evaluate("Hello {{> plic}}")).to eq("Hello Plic")
      end

      it 'using context' do
        hbs.register_partial('brackets', "[{{name}}]")
        expect(evaluate("Hello {{> brackets}}", {name: 'world'})).to eq("Hello [world]")
      end
    end

    context 'helpers' do
      it 'without any argument' do
        hbs.register_helper('rainbow') {|context| "-"}
        expect(evaluate("{{rainbow}}")).to eq("-")
      end

      it 'with a single argument' do
        hbs.register_helper('noah') {|context, value| value.gsub(/a/, '')}

        expect(evaluate("{{noah country}}", {country: 'Canada'})).to eq("Cnd")
      end

      it 'with multiple arguments, including strings' do
        hbs.register_helper('add') {|context, left, op, right| "#{left} #{op} #{right}"}

        expect(evaluate("{{add left '&' right}}", {left: 'Law', right: 'Order'})).to eq("Law & Order")
      end

      it 'with an empty string argument' do
        hbs.register_helper('noah') {|context, value| value.to_s.gsub(/a/, '')}

        expect(evaluate("hey{{noah ''}}there", {})).to eq("heythere")
      end

      it 'block' do
        hbs.register_helper('comment') do |context, commenter, block|
          block.fn(context).split("\n").map do |line|
            "#{commenter} #{line}"
        end.join("\n")

        expect(evaluate([
          "{{comment '//'}}",
          "Author: {{author.name}}, {{author.company}}",
          "Date: {{commit_date}}",
          "{{/comment}}"
        ].join("\n"), {author: {name: 'Vincent', company: 'Hiptest'}, commit_date: 'today'})).to eq([
          "// Author: Vincent, Hiptest",
          "// Date: today"
        ].join("\n"))
        end
      end

      it 'block without arguments' do
        template = [
          "<tr>{{#indent}}",
          "{{#each items}}<td>{{{ this }}}</td>",
          "{{/each}}",
          "{{/indent}}",
          "</tr>"
        ].join("\n")

        hbs.register_helper('indent') do |context, block|
          block.fn(context).split("\n").map do |line|
            "  #{line}"
          end.join("\n")
        end

        expect(evaluate(template, {items: ['a', 'b', 'c']})).to eq([
          "<tr>  ",
          "  <td>a</td>",
          "  <td>b</td>",
          "  <td>c</td>",
          "</tr>"
        ].join("\n"))
      end

      it 'block parameters can be paths' do
        data = {company: {people: ['a', 'b', 'c']}}
        expect(evaluate("{{#each company.people}}{{{this}}}{{/each}}", data)).to eq('abc')
      end
    end

    context 'default helpers' do
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

      context 'each' do
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
      end
    end
  end
end
