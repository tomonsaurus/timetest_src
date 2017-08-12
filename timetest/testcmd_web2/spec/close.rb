require 'spec_helper'
require 'time'

describe server(:app) do
  describe capybara('http://app') do
    
    it "responds content including 'close in web2" do
      visit '/limitpage_web2_11_12.php'
      
      expect(page).to have_content('close web2...')
      
    end
  end
end


