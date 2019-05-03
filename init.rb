# encoding: UTF-8

require 'redmine'

###################
# 1/ Initialisation
Rails.logger.info 'o=>'
Rails.logger.info 'o=>Starting Smile Auto User Activation plugin for Redmine'
Rails.logger.info "o=>Application user : #{ENV['USER']}"


plugin_name = :redmine_smile_auto_user_activation
plugin_root = File.dirname(__FILE__)

# If not brought by other plugin
unless defined?(SmileTools)
  # lib/not_reloaded
  require plugin_root + '/lib/not_reloaded/smile_tools'
  require plugin_root + '/lib/not_reloaded/plugin_config'
end


Redmine::Plugin.register plugin_name do
  ########################
  # 2/ Plugin informations
  name 'Redmine - Smile - Auto User Activation'
  author 'Jérôme BATAILLE'
  author_url "mailto:Jerome BATAILLE <redmine-support@smile.fr>?subject=#{plugin_name}"
  description "Adds new User Automatic Activation when User is added in it's first project, at this moment User can optionally be added to a default Group"
  url "https://github.com/Smile-SA/#{plugin_name}"
  version '1.0.4'
  requires_redmine :version_or_higher => '2.6.1'

  #######################
  # 2.1/ Plugin home page
  settings :default => HashWithIndifferentAccess.new(
    ),
    :partial => "settings/#{plugin_name}"

end # Redmine::Plugin.register ...


#################################
# 3/ Plugin internal informations
# To keep after plugin register
this_plugin = Redmine::Plugin::find(plugin_name.to_s)
plugin_version = '?.?'
# Root relative to application root
plugin_rel_root = '.'
plugin_id = 0
if this_plugin
  plugin_version  = this_plugin.version
  plugin_id       = this_plugin.__id__
  plugin_rel_root = 'plugins/' + this_plugin.id.to_s
end


###############
# 4/ Dispatcher
if Rails::VERSION::MAJOR < 3
  require 'dispatcher'
end

#Executed each time the classes are reloaded
if !defined?(rails_dispatcher)
  if Rails::VERSION::MAJOR < 3
    rails_dispatcher = Dispatcher
  else
    rails_dispatcher = Rails.configuration
  end
end

###############
# 5/ to_prepare
# Executed after Rails initialization
rails_dispatcher.to_prepare do
  Rails.logger.info "o=>"
  Rails.logger.info "o=>\\__ #{plugin_name} V#{plugin_version}"

  SmileTools.reset_override_count(plugin_name)

  SmileTools.trace_override "                                plugin  #{plugin_name} V#{plugin_version}",
    true,
    :redmine_smile_auto_user_activation


  #########################################
  # 5.1/ List of files required dynamically
  # Manage dependencies
  # To put here if we want recent source files reloaded
  # Outside of to_prepare, file changed => reloaded,
  # but with primary loaded source code
  required = [
    # lib/

    # lib/controllers
    '/lib/controllers/smile_controllers_members',

    # lib/helpers
    '/lib/helpers/smile_helpers_application',
    '/lib/helpers/smile_helpers_members',
    '/lib/helpers/smile_helpers_groups',
    '/lib/helpers/smile_helpers_users',

    # lib/models
    '/lib/models/smile_models_principal',
  ]

  if Rails.env == "development"
    ###########################
    # 5.2/ Dynamic requirements
    Rails.logger.debug "o=>require_dependency"
    required.each{ |d|
      # Reloaded each time modified
      Rails.logger.debug "o=>  #{plugin_rel_root + d}"
      require_dependency plugin_root + d
    }
    required = nil

    # Folders whose contents should be reloaded, NOT including sub-folders

#    ActiveSupport::Dependencies.autoload_once_paths.reject!{|x| x =~ /^#{Regexp.escape(plugin_root)}/}

    autoload_plugin_paths = ['/lib/controllers', '/lib/helpers', '/lib/models']

    Rails.logger.debug 'o=>'
    Rails.logger.debug "o=>autoload_paths / watchable_dirs +="
    autoload_plugin_paths.each{|p|
      new_path = plugin_root + p
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      ActiveSupport::Dependencies.autoload_paths << new_path
      rails_dispatcher.watchable_dirs[new_path] = [:rb]
    }
  else
    ##########################
    # 5.3/ Static requirements
    Rails.logger.debug "o=>require"
    required.each{ |p|
      # Never reloaded
      Rails.logger.debug "o=>  #{plugin_rel_root + p}"
      require plugin_root + p
    }
  end
  # END -- Manage dependencies


  ##############
  # 6/ Overrides

  #***************************
  # **** 6.1/ Controllers ****
  Rails.logger.info "o=>----- CONTROLLERS"
  unless MembersController.include? Smile::Controllers::MembersOverride::AutoUserActivation
    # Rails.logger.info "o=>MembersController.prepend Smile::Controllers::MembersOverride::AutoUserActivation"
    MembersController.send(:prepend, Smile::Controllers::MembersOverride::AutoUserActivation)
  end


  #***********************
  # **** 6.2/ Helpers ****
  Rails.logger.info "o=>----- HELPERS"
  ApplicationHelper.send(:prepend, Smile::Helpers::ApplicationOverride::AutoUserActivation)

  unless MembersHelper.include? Smile::Helpers::MembersOverride::AutoUserActivation
    # Rails.logger.info "o=>MembersHelper.extend Smile::Helpers::MembersOverride::AutoUserActivation"
    # MembersHelper is a module
    MembersHelper.send(:prepend, Smile::Helpers::MembersOverride::AutoUserActivation)
  end

  unless GroupsHelper.include? Smile::Helpers::GroupsOverride::AutoUserActivation
    # Rails.logger.info "o=>GroupsHelper.extend Smile::Helpers::GroupsOverride::AutoUserActivation"
    # MembersHelper is a module
    GroupsHelper.send(:prepend, Smile::Helpers::GroupsOverride::AutoUserActivation)
  end

  unless UsersHelper.include? Smile::Helpers::UsersOverride::AutoUserActivation
    # Rails.logger.info "o=>UsersHelper.extend Smile::Helpers::UsersOverride::AutoUserActivation"
    # UsersHelper is a module
    UsersHelper.send(:prepend, Smile::Helpers::UsersOverride::AutoUserActivation)
  end


  #**********************
  # **** 6.3/ Models ****
  Rails.logger.info "o=>----- MODELS"
  unless Principal.include? Smile::Models::PrincipalOverride::AutoUserActivation
    # Rails.logger.info "o=>Principal.prepend Smile::Models::PrincipalOverride::AutoUserActivation
    Principal.send(:prepend, Smile::Models::PrincipalOverride::AutoUserActivation)
  end



  # keep traces if classes / modules are reloaded
  SmileTools.enable_traces(false, plugin_name)

  Rails.logger.info 'o=>/--'
end
