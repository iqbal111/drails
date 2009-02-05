####################################################################
#                                                                  #
#      Copyright (c) 2008, Bob Remeika and others                  #
#      All Rights Reserved.                                        #
#                                                                  #
#      Licensed under the MIT License.                             #
#      For more information on d-rails licensing, see:             #
#                                                                  #
#          http://www.opensource.org/licenses/mit-license.php      #
#                                                                  #
####################################################################

require File.join(File.dirname(__FILE__), "../spec_helper.rb")

class TestView
  include ActionView::Helpers::PrototypeHelper
  include ActionView::Helpers::JavaScriptHelper

  def url_for(params)
    return "http://somemockurl.com"
  end

  def protect_against_forgery?
    false
  end
  
  def request_forgery_protection_token
    "my_request_forgery_protection_token"
  end
end

describe Drails::PrototypeHelper do
  attr_reader :test_view
  before do
    @test_view = TestView.new
    Drails::PrototypeOverride.override
  end

  describe "#periodically_call_remote_with_dojo" do
    attr_reader :helper_output

    before do
      @helper_output = test_view.periodically_call_remote
      helper_output.should_not be_blank
    end

  end

  describe "#remote_function" do
    before do
      @helper_output = test_view.remote_function
      helper_output.should_not be_blank
    end
  end

  describe "#options_for_ajax" do
    attr_reader :default_options
    before do
      @default_options = {
        'asynchronous' => true,
        'evalScripts' => true
      }
    end

    describe "when supported callbacks are passed" do
      it "returns the callbacks as part of the ajax options" do
        expected_options = default_options.merge(
          "onComplete" => "function(request){alert('complete')}",
          "onSuccess" => "function(request){alert('success')}",
          "onFailure" => "function(request){alert('failure')}"
          )
        params = { :success => "alert('success')", :complete => "alert('complete')", :failure => "alert('failure')" }
        actual_options = test_view.send(:options_for_ajax, params)
        dirty_json_decode(actual_options).should include_options(expected_options)
      end
    end
    
    describe "when :form is passed" do
      it "returns a dojo function for form serialization in 'parameters'" do
        expected_options = default_options.merge(
          "parameters" => "dojo.formToQuery(this)"
          )
        params = { :form => true }
        actual_options = test_view.send(:options_for_ajax, params)
        dirty_json_decode(actual_options).should include_options(expected_options)
      end
    end
    
    describe "when :submit is passed" do
      it "returns a dojo function for form serialization in 'parameters'" do
        expected_options = default_options.merge(
          "parameters" => "dojo.formToQuery('myForm')"
          )
        params = { :submit => 'myForm' }
        actual_options = test_view.send(:options_for_ajax, params)
        dirty_json_decode(actual_options).should include_options(expected_options)
      end
    end
    
    describe "when protect_against_forgery? is true" do
      before do
        mock(test_view).protect_against_forgery? { true }
        mock(test_view).form_authenticity_token { "my_token" }
      end
      
      it "returns a dojo function for form serialization in 'parameters'" do
        expected_options = default_options.merge(
          "parameters" => "'my_request_forgery_protection_token=' + encodeURIComponent('my_token')"
          )
        actual_options = test_view.send(:options_for_ajax, {})
        dirty_json_decode(actual_options).should include_options(expected_options)
      end
    end
  end

end