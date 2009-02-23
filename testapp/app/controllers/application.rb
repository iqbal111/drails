# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  layout "base"
  
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  #protect_from_forgery # :secret => 'fe5ff5df0920a8e5aec44e1ca40f7ccb'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  before_filter :set_drails_config
  
  def set_drails_config
    @drails_config = YAML.load(File.open("#{RAILS_ROOT}/vendor/plugins/d-rails/config/drails.yml"))
  end
  
end
