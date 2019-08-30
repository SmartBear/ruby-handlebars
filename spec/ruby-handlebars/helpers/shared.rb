shared_context "shared apply helper" do
  # Use to test which blocks are called based on the params values.
  let(:block) { double(Handlebars::Tree::Block.new([])) }
  let(:else_block) { double(Handlebars::Tree::Block.new([])) }

  before do
    allow(block).to receive(:fn)
    allow(else_block).to receive(:fn)
  end
end

shared_context "shared helpers integration tests" do
  let(:hbs) {Handlebars::Handlebars.new}

  def evaluate(template, args = {})
    hbs.compile(template).call(args)
  end
end

shared_examples "a registerable helper" do |name|
  it "registers the \"#{name}\" helper" do
    hbs = double(Handlebars::Handlebars)
    allow(hbs).to receive(:register_helper)
    allow(hbs).to receive(:register_as_helper)

    subject.register(hbs)

    expect(hbs)
      .to have_received(:register_helper)
      .once
      .with(name)
  end
end

shared_examples "a helper running the main block" do |title, params|
  include_context "shared apply helper"

  it "when condition is #{title}" do
    subject.apply(hbs, params, block, else_block)

    expect(block).to have_received(:fn).once
    expect(else_block).not_to have_received(:fn)
  end
end

shared_examples "a helper running the else block" do |title, params|
  include_context "shared apply helper"

  it "when condition is #{title}" do
    subject.apply(hbs, params, block, else_block)

    expect(block).not_to have_received(:fn)
    expect(else_block).to have_received(:fn).once
  end
end
