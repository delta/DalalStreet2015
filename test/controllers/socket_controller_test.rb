require 'test_helper'

class SocketControllerTest < ActionController::TestCase
  
  include Devise::TestHelpers                          
  include Warden::Test::Helpers                        
  Warden.test_mode!                                    

  def teardown                                         
    Warden.test_reset!                                 
  end       

  # test "the truth" do
  #   assert true
  # end
end
