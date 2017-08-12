require 'spec_helper'

describe server(:app) do
  describe capybara('http://app') do
    it "responds content including 'close...' in web1" do
      visit '/limitpage_web1_10_13.php'
      expect(page).to have_content('close web1...')
    end
  end


end


