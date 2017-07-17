require 'spec_helper'

describe server(:app) do
  describe http('http://app') do
    it "responds content including 'phptest'" do
      expect(response.body).to include('phptest')
    end
    it "responds as 'text/html'" do
      expect(response.headers['content-type']).to eq("text/html; charset=UTF-8")
    end
  end

  describe capybara('http://app') do
    it "responds content including 'close...'" do
      visit '/limitpage.php'
      expect(page).to have_content('close...')
    end
  end



end


