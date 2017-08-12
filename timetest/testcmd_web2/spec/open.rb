require 'spec_helper'
require 'time'

describe server(:app) do
  describe capybara('http://app') do
    
    it "responds content including 'HELLO web2' between 11 and 12 in web2" do
      visit '/limitpage_web2_11_12.php'
      
      #puts 'TEST_SERVER_TIME:' + ENV['TEST_SERVER_TIME']
      
      #t = ENV['TEST_SERVER_TIME']
      
      #testtime = Time.parse(t)
      
      #startday = Time.parse('2017-08-01 11:00:00')
      #endday   = Time.parse('2017-08-01 12:00:00')
      
      #if testtime < startday && testtime > endday
        expect(page).to have_content('HELLO web2')
      #else
      #  expect(page).to have_content('close...')
      #end
        
      
      
    end
  end



end


