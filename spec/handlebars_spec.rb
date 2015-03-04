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

      it 'with a block' do
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
    end
  end
end