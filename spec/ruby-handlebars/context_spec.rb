require_relative '../spec_helper'
require_relative '../../lib/ruby-handlebars/context'

describe Handlebars::Context do
  let(:ctx) { described_class.new(nil, data) }

  context 'get' do
    let(:data) { {
      key_data: 'Some value'
    } }

    before do
      ctx.add_item(:key_locals, 'Some other value')
      ctx.add_item(:a_list, ['a', 'b', 'c'])
      ctx.add_item(:a_hash, {key: 'A third value'})
    end

    it 'fetches data stored in the context' do
      expect(ctx.get('key_data')).to eq('Some value')
      expect(ctx.get('key_locals')).to eq('Some other value')
    end

    it 'uses data from @locals before @data' do
      ctx.add_item(:key_data, 'Now stored in @locals')

      expect(ctx.get('key_data')).to eq('Now stored in @locals')
    end

    context 'when digging inside data' do
      it 'uses keys separated by dots' do
        expect(ctx.get('a_hash.key')).to eq('A third value')
      end

      it 'can also use methods' do
        expect(ctx.get('a_list.first')).to eq('a')
        expect(ctx.get('a_list.last')).to eq('c')
      end
    end
  end

  context 'add_item' do
    let(:data) { {} }

    it 'adds a new key to the stored data' do
      expect(ctx.get('my_key')).to be nil
      ctx.add_item('my_key', 'With some value')
      expect(ctx.get('my_key')).to eq('With some value')
    end

    it 'overrides existing values' do
      ctx.add_item('a', 12)
      ctx.add_item('a', 25)

      expect(ctx.get('a')).to eq(25)
    end

    it 'does not make differences between string and sym keys' do
      ctx.add_item('a', 12)
      ctx.add_item(:a, 25)

      expect(ctx.get('a')).to eq(25)
    end
  end

  context 'add_items' do
    let(:data) { {} }

    it 'is basically a wrapper around add_item to add multiple items' do
      allow(ctx).to receive(:add_item)

      ctx.add_items(a: 'One key', b: 'A second key', c: 'A third key')
      expect(ctx).to have_received(:add_item).at_most(3).times
      expect(ctx).to have_received(:add_item).once.with(:a, 'One key')
      expect(ctx).to have_received(:add_item).once.with(:b, 'A second key')
      expect(ctx).to have_received(:add_item).once.with(:c, 'A third key')
    end
  end

  context 'with_temporary_context' do
    let(:data) { {} }

    before do
      ctx.add_items(
        key: 'some key',
        value: 'some value'
      )
    end

    it 'allows creating temporary variables' do
      expect(ctx.get('unknown_key')).to be nil

      ctx.with_temporary_context(unknown_key: 42) do
        expect(ctx.get('unknown_key')).to eq(42)
      end
    end

    it 'can override an existing variable' do
      ctx.with_temporary_context(value: 'A completelly new value') do
        expect(ctx.get('value')).to eq('A completelly new value')
      end
    end

    it 'provides mutable variables (well, variables ...)' do
      ctx.with_temporary_context(unknown_key: 42) do
        expect(ctx.get('unknown_key')).to eq(42)
        ctx.add_item('unknown_key', 56)
        expect(ctx.get('unknown_key')).to eq(56)
      end
    end

    it 'after the block, existing variables are restored' do
      ctx.with_temporary_context(value: 'A completelly new value') do
        expect(ctx.get('value')).to eq('A completelly new value')
      end

      expect(ctx.get('value')).to eq('some value')
    end

    it 'after the block, the declared variables are not available anymore' do
      ctx.with_temporary_context(unknown_key: 42) do
        expect(ctx.get('unknown_key')).to eq(42)
      end

      expect(ctx.get('unknown_key')).to be nil
    end

    it 'returns the data executed by the block' do
      expect( ctx.with_temporary_context(value: 'A completelly new value') { 12 } ).to eq(12)
    end

    context 'when data are stored in @data' do
      let(:data) { {my_key: "With some value"} }

      it 'let them available after the block is executed' do
        expect(ctx.get('my_key')).to eq('With some value')

        ctx.with_temporary_context(my_key: 12) do
          expect(ctx.get('my_key')).to eq(12)
        end

        expect(ctx.get('my_key')).to eq('With some value')
      end
    end
  end
end
