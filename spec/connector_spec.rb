# frozen_string_literal: true

require 'byebug'
require 'spec_helper.rb'

RSpec.describe 'connector', :vcr do
  let(:settings) { Workato::Connector::Sdk::Settings.from_encrypted_file('settings.yaml.enc')[:jira] }
  let(:connector) { Workato::Connector::Sdk::Connector.from_file('connector.rb', settings) }

  it { expect(connector).to be_present }

  describe 'test' do
    subject(:output) { connector.test(settings) }

    context 'given valid credentials' do
      it 'establishes valid connection' do
        expect(output).to be_truthy
      end

      it 'verifies account email' do
        expect(output[:emailAddress]).to eq settings[:username]
      end

      it 'returns response that is not excessively large' do
        expect(output.to_s.length).to be < 5000
      end
    end
  end
end
