# Smile - members_helper enhancement
# module Smile::Helpers::MembersOverride
#
# - 1/ #24789 Projet Leaders to activate users
#   2011-08-04
#   RM: #8979
#   module ::AutoUserActivation


module Smile
  module Helpers
    module MembersOverride
      #**********************
      # 1/ AutoUserActivation
      module AutoUserActivation
        def self.prepended(base)
          auto_user_activation_instance_methods = [
            :render_principals_for_new_members # 1/ REWRITTEN, RM 4.0.0 OK
          ]

          base.module_eval do
            # 1/ REWRITTEN, RM 4.0.0 OK
            # Smile specific #24789 Projet Leaders to activate users
            def render_principals_for_new_members(project, limit=100)
              ########################################################
              # Smile specific #24789 Projet Leaders to activate users
              # Smile specific : active -> active_or_to_activate
              scope = Principal.active_or_to_activate

              # Smile specific : visible -> visible_any_status
              scope = scope.visible_any_status.sorted.not_member_of(project).like(params[:q])
              # END Smile specific #24789 Projet Leaders to activate users
              ############################################################

              principal_count = scope.count
              principal_pages = Redmine::Pagination::Paginator.new principal_count, limit, params['page']
              principals = scope.offset(principal_pages.offset).limit(principal_pages.per_page).to_a

              ########################################################
              # Smile specific #24789 Projet Leaders to activate users
              # link to user enabled + grey color for users to activate (3rd param = true)
              s = content_tag('div',
                content_tag('div', principals_check_box_tags('membership[user_ids][]', principals, true), :id => 'principals'),
                :class => 'objects-selection'
              )

              links = pagination_links_full(principal_pages, principal_count, :per_page_links => false) {|text, parameters, options|
                link_to text, autocomplete_project_memberships_path(project, parameters.merge(:q => params[:q], :format => 'js')), :remote => true
              }

              s + content_tag('span', links, :class => 'pagination')
            end
          end # base.module_eval do


          trace_prefix       = "#{' ' * (base.name.length + 18)}  --->  "
          last_postfix       = '< (SM::HO::MembersOverride::AutoUserActivation)'

          smile_instance_methods = base.instance_methods.select{|m|
              auto_user_activation_instance_methods.include?(m) &&
                base.instance_method(m).source_location.first =~ SmileTools.regex_path_in_plugin('lib/helpers/smile_helpers_members', 'redmine_smile_auto_user_activation')
            }

          missing_instance_methods = auto_user_activation_instance_methods.select{|m|
            !smile_instance_methods.include?(m)
          }

          if missing_instance_methods.any?
            trace_first_prefix = "#{base.name} MISS    instance_methods  "
          else
            trace_first_prefix = "#{base.name}         instance_methods  "
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
    end # module MembersOverride
  end # module Helpers
end # module Smile
