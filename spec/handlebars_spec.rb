require_relative 'spec_helper'
require_relative '../lib/ruby-handlebars'
require_relative '../lib/ruby-handlebars/escapers/dummy_escaper'


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

    it 'a double braces replacement with unsafe characters' do
      expect(evaluate('Hello {{name}}', {name: '<"\'>&'})).to eq('Hello &lt;&quot;&#39;&gt;&amp;')
    end

    it 'a double braces replacement with nil' do
      expect(evaluate('Hello {{name}}', {name: nil})).to eq('Hello ')
    end

    it 'a triple braces replacement with unsafe characters' do
      expect(evaluate('Hello {{{name}}}', {name: '<"\'>&'})).to eq('Hello <"\'>&')
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

        expect(evaluate("{{add left '&' right}}", {left: 'Law', right: 'Order'})).to eq("Law &amp; Order")
        expect(evaluate("{{{add left '&' right}}}", {left: 'Law', right: 'Order'})).to eq("Law & Order")
      end

      it 'with an empty string argument' do
        hbs.register_helper('noah') {|context, value| value.to_s.gsub(/a/, '')}

        expect(evaluate("hey{{noah ''}}there", {})).to eq("heythere")
      end

      it 'with helpers as arguments' do
        hbs.register_helper('wrap_parens') {|context, value| "(#{value})"}
        hbs.register_helper('wrap_dashes') {|context, value| "-#{value}-"}

        expect(evaluate('{{wrap_dashes (wrap_parens "hello")}}', {})).to eq("-(hello)-")
        expect(evaluate('{{wrap_dashes (wrap_parens world)}}', {world: "world"})).to eq("-(world)-")
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

      it 'a else keyword out of a helper will raise an error' do
        expect { evaluate('My {{ else }} template') }.to raise_exception(Parslet::ParseFailed)
      end
    end
  end

  context 'escaping characters' do
    let(:escaper) { nil }
    let(:name) { '<"\'>&' }
    let(:replacement_escaped) { evaluate('Hello {{ name }}', {name: name}) }
    let(:helper_replacement_escaped) {
      hbs.register_helper('wrap_parens') {|context, value| "(#{value})"}
      evaluate('Hello {{wrap_parens name}}', {name: name})
    }

    before do
      hbs.set_escaper(escaper)
    end

    context 'default escaper' do
      it 'escapes HTML characters in simple replacements' do
        expect(replacement_escaped).to eq('Hello &lt;&quot;&#39;&gt;&amp;')
      end

      it 'escapes HTML characters in helpers' do
        expect(helper_replacement_escaped).to eq('Hello (&lt;&quot;&#39;&gt;&amp;)')
      end
    end

    context 'DummyEscaper' do
      let(:escaper) { Handlebars::Escapers::DummyEscaper }

      it 'escapes nothing' do
        expect(replacement_escaped).to eq('Hello <"\'>&')
      end

      it 'escapes nothing in helpers' do
        expect(helper_replacement_escaped).to eq('Hello (<"\'>&)')
      end
    end

    context 'custom escaper' do
      class VowelEscaper
        def self.escape(value)
          value.gsub(/([aeiuo])/, '-\1')
        end
      end

      let(:escaper) { VowelEscaper }
      let(:name) { 'Her Serene Highness' }

      it 'applies the escaping' do
        expect(replacement_escaped).to eq('Hello H-er S-er-en-e H-ighn-ess')
      end

      it 'applies the escaping in helpers' do
        expect(helper_replacement_escaped).to eq('Hello (H-er S-er-en-e H-ighn-ess)')
      end
    end
  end

  context 'regression tests' do
    context 'when an unknown helper is called in a template' do
      it 'should provide a useful error message with inline helpers' do
        expect{ evaluate('{{unknown "This will hardly work" }}') }.to raise_exception(Handlebars::UnknownHelper, 'Helper "unknown" does not exist')
      end

      it 'should provide a useful error message with block helpers' do
        expect{ evaluate('{{#unknown}}This will hardly work{{/unknown}}') }.to raise_exception(Handlebars::UnknownHelper, 'Helper "unknown" does not exist')
      end
    end
  end
end
