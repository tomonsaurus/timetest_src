require 'spec_helper'

describe server(:app) do
  describe capybara('http://app') do
    it "responds content including 'HELLO web1' between 10 and 13 in web1" do
      visit '/limitpage_web1_10_13.php'
      expect(page).to have_content('HELLO web1')
    end
  end



end


