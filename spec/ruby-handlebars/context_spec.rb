require_relative '../spec_helper'
require_relative '../../lib/ruby-handlebars/context'

describe Handlebars::Context do
  include Handlebars::Context

  context 'get' do
    before do
      @data = {
        key_data: 'Some value'
      }

      @locals = {
        key_locals: 'Some other value',
        a_list: ['a', 'b', 'c'],
        a_hash: {key: 'A third value'}
      }
    end

    it 'fetches data stored in the context' do
      expect(get('key_data')).to eq('Some value')
      expect(get('key_locals')).to eq('Some other value')
    end

    it 'uses data from @locals before @data' do
      @locals[:key_data] = 'Now stored in @locals'

      expect(get('key_data')).to eq('Now stored in @locals')
    end

    context 'when digging inside data' do
      it 'uses keys separated by dots' do
        expect(get('a_hash.key')).to eq('A third value')
      end

      it 'can also use methods' do
        expect(get('a_list.first')).to eq('a')
        expect(get('a_list.last')).to eq('c')
      end
    end
  end

  context 'add_item' do
    it 'adds a new key to the stored data' do
      expect(get('my_key')).to be nil
      add_item('my_key', 'With some value')
      expect(get('my_key')).to eq('With some value')
    end

    it 'overrides existing values' do
      add_item('a', 12)
      add_item('a', 25)

      expect(get('a')).to eq(25)
    end

    it 'does not make differences between string and sym keys' do
      add_item('a', 12)
      add_item(:a, 25)

      expect(get('a')).to eq(25)
    end
  end

  context 'add_items' do
    it 'is basically a wrapper around add_item to add multiple items' do
      allow(self).to receive(:add_item)

      add_items(a: 'One key', b: 'A second key', c: 'A third key')
      expect(self).to have_received(:add_item).at_most(3).times
      expect(self).to have_received(:add_item).once.with(:a, 'One key')
      expect(self).to have_received(:add_item).once.with(:b, 'A second key')
      expect(self).to have_received(:add_item).once.with(:c, 'A third key')
    end
  end

  context 'with_temporary_context' do
    before do
      add_items(
        key: 'some key',
        value: 'some value'
      )
    end

    it 'allows creating temporary variables' do
      expect(get('unknown_key')).to be nil

      with_temporary_context(unknown_key: 42) do
        expect(get('unknown_key')).to eq(42)
      end
    end

    it 'can override an existing variable' do
      with_temporary_context(value: 'A completelly new value') do
        expect(get('value')).to eq('A completelly new value')
      end
    end

    it 'provides mutable variables (well, variables ...)' do
      with_temporary_context(unknown_key: 42) do
        expect(get('unknown_key')).to eq(42)
        add_item('unknown_key', 56)
        expect(get('unknown_key')).to eq(56)
      end
    end

    it 'after the block, existing variables are restored' do
      with_temporary_context(value: 'A completelly new value') do
        expect(get('value')).to eq('A completelly new value')
      end

      expect(get('value')).to eq('some value')
    end

    it 'after the block, the declared variables are not available anymore' do
      with_temporary_context(unknown_key: 42) do
        expect(get('unknown_key')).to eq(42)
      end

      expect(get('unknown_key')).to be nil
    end

    it 'returns the data executed by the block' do
      expect( with_temporary_context(value: 'A completelly new value') { 12 } ).to eq(12)
    end

    context 'when data are stored in @data' do
      before do
        @data = {my_key: "With some value"}
      end

      it 'let them available after the block is executed' do
        expect(get('my_key')).to eq('With some value')

        with_temporary_context(my_key: 12) do
          expect(get('my_key')).to eq(12)
        end

        expect(get('my_key')).to eq('With some value')
      end
    end
  end
end