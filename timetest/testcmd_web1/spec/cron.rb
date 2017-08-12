require 'spec_helper'
describe server(:app) do
  let(:time) { Time.now }
  
  it "executes a command on the current server" do
    #p ENV
    puts 'TEST_SERVER_TIME:' + ENV['TEST_SERVER_TIME']
    
    t = ENV['TEST_SERVER_TIME']
    h = t[11..12]
    #puts h
    tr = t[0..-3] + "[0-9]{2}\tfixed"  + h + " END"
    #puts tr
    
    
    result = current_server.ssh_exec("tail -n 7 /home/vagrant/src/batch/cronexec.log ")
    #puts result
    
    expect(result).to match(/#{tr}/)

  end
end






