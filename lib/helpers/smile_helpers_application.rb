# Smile - application_helper enhancement
# module Smile::Helpers::ApplicationOverride
#
# - 1/ module ::AutoUserActivation
#      - #24789 Project Leaders can activate users, users to activate in lightgray
#        2011-08-05
#        RM: #8979


module Smile
  module Helpers
    module ApplicationOverride
      #######################
      # 1/ AutoUserActivation
      module AutoUserActivation
        def self.prepended(base)
          auto_user_activation_instance_methods = [
            :principals_check_box_tags, # 1/ OVERRDIDEN rewritten V4.0.0 OK
          ]

          base.module_eval do
            #***********************
            # 1/ OVERRIDEN rewritten, RM 4.0.0 OK
            # Smile specific #24789 Project Leaders can activate users, users to activate in lightgray
            # - optional parameter added ; p_link
            # - not enabled by default
            def principals_check_box_tags(name, principals, p_link=false)
              s = ''

              principals.each do |principal|
                ################################################################################
                # Smile specific #24789 Project Leaders can activate users, users to activate in lightgray
                principal_label = h(principal)
                # optional link to user
                principal_label = link_to(principal_label, principal) if (p_link && !principal.is_a?(GroupBuiltin))
                # END -- Smile specific #24789 Project Leaders can activate users, users to activate in lightgray
                ####################################################################################

                # Smile specific #24789 Project Leaders can activate users, users to activate in lightgray
                # Smile specific : class status, principal_label with optional link,
                s << "<label class=\"status-#{principal.status}\">#{ check_box_tag name, principal.id, false, :id => nil } #{principal_label}</label>\n"
              end
              s.html_safe
            end
          end # base.module_eval do

          smile_instance_methods = base.instance_methods.select{|m|
              auto_user_activation_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_application', 'redmine_smile_auto_user_activation')
            }

          missing_instance_methods = auto_user_activation_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          trace_prefix         = "#{' ' * (base.name.length + 15)}  --->  "
          module_name          = 'SM::HO::AppOverride::AutoUserActivation'
          last_postfix         = "< (#{module_name})"

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MIS instance_methods  "
          else
            trace_first_prefix = "#{base.name}     instance_methods  "
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
    end # module ApplicationOverride
  end # module Helpers
end # module Smile
