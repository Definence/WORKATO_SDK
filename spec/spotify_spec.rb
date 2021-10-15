# frozen_string_literal: true

require 'byebug'
require 'spec_helper.rb'

RSpec.describe 'connector', :vcr do
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc')[:spotify] }
  let(:connector) { Workato::Connector::Sdk::Connector.from_file('spotify.rb', settings) }

  it { expect(connector).to be_present }

  describe 'test' do
    subject(:output) { connector.test(settings) }

    context 'given valid credentials' do
      it 'establishes valid connection' do
        expect(output).to be_truthy
      end

      it 'verifies account email' do
        expect(output[:display_name]).to be_present
      end

      it 'returns response that is not excessively large' do
        expect(output.to_s.length).to be < 5000
      end
    end
  end

  describe 'execute' do
    subject(:output) { action.execute(settings, input) }

    context 'search_artists' do
      let(:action) { connector.actions.search_artists }
      let(:input) { JSON.parse(File.read('fixtures/actions/spotify/search_artists_input.json')) }
      let(:expected_output) { JSON.parse(File.read('fixtures/actions/spotify/search_artists_output.json')) }

      it 'returns a response with an artist' do
        expect(output).to eq(expected_output)
      end
    end
  end
end
