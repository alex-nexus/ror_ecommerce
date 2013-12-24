class Admin::Config::BaseController < Admin::BaseController
  add_breadcrumb "Configs", :admin_config_overviews_path

  skip_before_filter :verify_admin
  before_filter :verify_super_admin  # ONLY SUPER ADMINS should see this
  layout 'admin'
end
