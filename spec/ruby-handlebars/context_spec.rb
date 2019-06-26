require_relative '../spec_helper'
require_relative '../../lib/ruby-handlebars/context'

describe Handlebars::Context do
  include Handlebars::Context

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
  end
end