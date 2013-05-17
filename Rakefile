# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project/template/ios'
require 'bundler'

Bundler.require

require 'sugarcube'
require 'teacup'
require 'awesome_print_motion'
load 'app_sign_credentials.rb' # create your own file from app_sign_credentials.rb.sample


Motion::Project::App.setup do |app|
  # Use `rake config' to see complete project settings.
  app.name = 'Tasks'
  app.codesign_certificate =  AppSetting[:codesign_ceritifcate]
  app.provisioning_profile  = AppSetting[:provisioning_profile]
  app.pods do
    pod 'MagicalRecord', '2.1'
  end

end
