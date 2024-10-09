# frozen_string_literal: true

require_relative '../lib/sidekiq_poison_pill_remedy'

RSpec.describe SidekiqPoisonPillRemedy do
  it 'has a version number' do
    expect(SidekiqPoisonPillRemedy::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
