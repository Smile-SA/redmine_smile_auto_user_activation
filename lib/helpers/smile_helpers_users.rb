# Smile - users_helper enhancement
# module Smile::Helpers::UsersOverride
#
# - 1/ AutoUserActivation
#      #24789 Projet Leaders to activate users
#      Add an un-activate link if activated
#      2013-10-15

module Smile
  module Helpers
    module UsersOverride
      #**********************
      # 1/ AutoUserActivation
      module AutoUserActivation
        def self.prepended(base)
          auto_user_activation_instance_methods = [
            :change_status_link # 1/ REWRITTEN V4.0.0 OK
          ]

          base.module_eval do
            # 1/ REWRITTEN, RM 4.0.0 OK
            # Smile specific #24789 Projet Leaders to activate users
            # Smile specific : add an un-activate link
            def change_status_link(user)
              url = {:controller => 'users', :action => 'update', :id => user, :page => params[:page], :status => params[:status], :tab => nil}

              if user.locked?
                link_to l(:button_unlock), url.merge(:user => {:status => User::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
              elsif user.registered?
                link_to l(:button_activate), url.merge(:user => {:status => User::STATUS_ACTIVE}), :method => :put, :class => 'icon icon-unlock'
              else
                links = ''.html_safe
                ########################################################
                # Smile specific #24789 Projet Leaders to activate users
                # Smile specific : link to cancel activation
                if user.active?
                  links += link_to l(:button_cancel) + ' ' + l(:button_activate), url.merge(:user => {:status => User::STATUS_REGISTERED}), :method => :put, :class => 'icon icon-unlock'
                end
                if user != User.current
                  # Smile specific : line feed
                  links += '<br/>'.html_safe if links.present?
                  links += link_to l(:button_lock), url.merge(:user => {:status => User::STATUS_LOCKED}), :method => :put, :class => 'icon icon-lock'
                end

                links
              end
            end
          end # base.module_eval do


          trace_prefix       = "#{' ' * (base.name.length + 18)}  --->  "
          last_postfix       = '< (SM::HO::UsersOverride::AutoUserActivation)'

          smile_instance_methods = base.instance_methods.select{|m|
              auto_user_activation_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_users', 'redmine_smile_auto_user_activation')
            }

          missing_instance_methods = auto_user_activation_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS      instance_methods  "
          else
            trace_first_prefix = "#{base.name}           instance_methods  "
          end

          SmileTools::trace_by_line(
            (
              missing_instance_methods.any? ?
              missing_instance_methods :
              smile_instance_methods
            ),
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_smile_auto_user_activation
          )

          if missing_instance_methods.any?
            raise trace_first_prefix + missing_instance_methods.join(', ') + '  ' + last_postfix
          end
        end # def self.prepended
      end # module AutoUserActivation
    end # module UsersOverride
  end # module Helpers
end # module Smile
