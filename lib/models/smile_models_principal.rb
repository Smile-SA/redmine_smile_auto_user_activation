# Smile - add methods to the Principal model
#
# module AutoUserActivation
# - #24789 Projects Leaders to activate users
#   RM: #8979
#   2011-08-03

#require 'active_support/concern' #Rails 3

module Smile
  module Models
    module PrincipalOverride
      #######################
      # 1/ AutoUserActivation
      module AutoUserActivation
        # extend ActiveSupport::Concern

        def self.prepended(base)
          # No sub-module included => no check if already included

          # Add instance methods calls in the class initialisation
          base.instance_eval do
            SmileTools.trace_override "#{base.name}                        scope  active_or_to_activate;visible_any_status < (SM::MO::PrincipalOverride::AutoUserActivation)",
              true,
              :redmine_smile_auto_user_activation

            # new scope RM V4.0.0 OK
            # TODO add tests on scopes
            ##########################################################
            # Smile specific #24789 Projects Leaders to activate users
            # WARNING do not use User constants here
            scope :active_or_to_activate, lambda{ where(:status => [Principal::STATUS_ACTIVE, Principal::STATUS_REGISTERED]) }

            # Rewrite of visible, RM V4.0.0 OK
            ########################################################
            # Smile specific #24789 Project Leaders users activation
            scope :visible_any_status, lambda {|*args|
              user = args.first || User.current

              if user.admin?
                all
              else
                view_all_active = false
                if user.memberships.to_a.any?
                  view_all_active = user.memberships.any? {|m| m.roles.any? {|r| r.users_visibility == 'all'}}
                else
                  view_all_active = user.builtin_role.users_visibility == 'all'
                end

                if view_all_active
                  #################################
                  # Smile spectific : active -> all
                  all
                else
                  # self and members of visible projects
                  where("#{table_name}.id = ? OR #{table_name}.id IN (SELECT user_id FROM #{Member.table_name} WHERE project_id IN (?))",
                    user.id, user.visible_project_ids
                  )
                end
              end
            }
          end

          def add_to_group(group)
            return false unless is_a?(User)

            return false if group.nil?

            return false if self.groups.pluck(:lastname).include?(group.name)

            added_to_group = false
            begin
              self.groups << group
              self.save

              added_to_group = true
            rescue Exception => e
              Rails.logger.error "Plugin redmine_smile_auto_user_activation, user #{self.login}, add_to_group #{group.name} : #{e.message}"
            end

            if added_to_group
              return group.name
            else
              return false
            end
          end
        end
      end # module AutoUserActivation
    end # module PrincipalOverride
  end # module Models
end # module Smile
