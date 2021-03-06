require 'spec_helper'
require 'active_support/inflector'
require 'app/models/repair'
require 'app/presenters/callback'
require 'app/presenters/appointment_presenter'
require 'app/presenters/confirmation'

RSpec.describe Confirmation do
  describe '#request_reference' do
    context 'when there is a work order' do
      it 'is the work order reference' do
        fake_api = instance_double('HackneyApi')
        allow(fake_api).to receive(:get_repair)
          .with(repair_request_reference: '00004578')
          .and_return(
            'repairRequestReference' => '00004578',
            'problemDescription' => 'My bath is broken',
            'priority' => 'N',
            'propertyReference' => '00034713',
            'workOrders' => [
              {
                'sorCode' => '20110010',
                'workOrderReference' => '00412371',
              },
            ]
          )
        expect(Confirmation.new(request_reference: '00004578', answers: {}, api: fake_api).request_reference)
          .to eq '00412371'
      end
    end

    context 'when there are no work orders' do
      it 'is the repair request reference' do
        fake_api = instance_double('HackneyApi')
        allow(fake_api).to receive(:get_repair)
          .with(repair_request_reference: '00004578')
          .and_return(
            'repairRequestReference' => '00004578',
            'problemDescription' => 'My bath is broken',
            'priority' => 'N',
            'propertyReference' => '00034713',
          )
        expect(Confirmation.new(request_reference: '00004578', answers: {}, api: fake_api).request_reference)
          .to eq '00004578'
      end
    end
  end

  describe 'address' do
    it 'builds an address from the selected answers' do
      fake_answers = {
        'address' => {
          'propertyReference' => '01234567',
          'address' => 'Ross Court 25',
          'postcode' => 'E5 8TE',
        },
      }

      expect(Confirmation.new(request_reference: '00000000', answers: fake_answers, api: double).address)
        .to eq 'Ross Court 25, E5 8TE'
    end
  end

  describe 'full_name' do
    it 'returns the stored name' do
      fake_answers = {
        'contact_details' => {
          'full_name' => 'Alan Groves',
        },
      }

      expect(Confirmation.new(request_reference: '00000000', answers: fake_answers, api: double).full_name)
        .to eq 'Alan Groves'
    end
  end

  describe 'telephone_number' do
    it 'strips out any spaces from stored phone numbers' do
      # TODO: this is an intial simple implementaion for simplicity.
      # At some point we should format numbers nicely, which will make it easier
      # to see if a mistake has been made
      fake_answers = {
        'contact_details' => {
          'telephone_number' => ' 0201 357 9753',
        },
      }

      expect(Confirmation.new(request_reference: '00000000', answers: fake_answers, api: double).telephone_number)
        .to eq '02013579753'
    end
  end

  describe 'scheduled_action' do
    context 'when there was a callback time' do
      it 'returns a renderable object' do
        fake_answers = {
          'callback_time' => {
            'callback_time' => ['morning'],
          },
        }
        action = Confirmation.new(request_reference: '00000000', answers: fake_answers, api: double).scheduled_action
        expect(action.to_partial_path).to eq '/confirmations/callback'
      end
    end

    context 'when there was an appointment' do
      it 'returns a renderable object' do
        fake_answers = {
          'appointment' => double, # TODO: replace with a more realistic value
        }
        action = Confirmation.new(request_reference: '00000000', answers: fake_answers, api: double).scheduled_action
        expect(action.to_partial_path).to eq '/confirmations/appointment'
      end
    end
  end
end
