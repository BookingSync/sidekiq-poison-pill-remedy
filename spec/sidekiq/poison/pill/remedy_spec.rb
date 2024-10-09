# frozen_string_literal: true

RSpec.describe Sidekiq::Poison::Pill::Remedy do
  it "has a version number" do
    expect(Sidekiq::Poison::Pill::Remedy::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
