# Smile - override methods to the Members controller
#
# 1/ module AutoUserActivation
# - InstanceMethods
#   #24789 RM: #8979, Project Leaders users activation
#   2011-08-04


#require 'active_support/concern' #Rails 3

module Smile
  module Controllers
    module MembersOverride
      module AutoUserActivation
        # extend ActiveSupport::Concern

        def self.prepended(base)
          auto_user_activation_methods = [
            :create, # 1/ REWRITTEN, RM 4.0.0 OK
          ]

          smile_instance_methods = base.instance_methods.select{|m|
              base.instance_method(m).owner == self
            }

          trace_first_prefix = "#{base.name}     instance_methods  "
          trace_prefix       = "#{' ' * (base.name.length - 4)}                     --->  "
          last_postfix       = '< (SM::CO::MembersOverride::AutoUserActivation)'

          SmileTools::trace_by_line(
            smile_instance_methods,
            trace_first_prefix,
            trace_prefix,
            last_postfix,
            :redmine_smile_auto_user_activation
          )
        end

        # 1/ REWRITTEN, RM 4.0.0 OK
        def create
          members = []

          ########################################################
          # Smile specific #24789 Project Leaders users activation
          users_to_activate = [] # Smile comment : for flash message

          if params[:membership]
            user_ids = Array.wrap(params[:membership][:user_id] || params[:membership][:user_ids])
            user_ids << nil if user_ids.empty?
            user_ids.each do |user_id|
              ########################################################
              # Smile specific #24789 Project Leaders users activation
              # Smile comment : Member, belongs_to :user, has_many :roles
              # Smile comment : {user_ids, roles_id}

              user = User.find_by_id(user_id)
              if user.present? && (user.type == 'User') && user.registered?
                # Will be activated later, if valid
                users_to_activate << user
              end
              # END -- Smile specific #24789 Project Leaders users activation
              ###############################################################

              member = Member.new(:project => @project, :user_id => user_id)
              member.set_editable_role_ids(params[:membership][:role_ids])
              members << member
            end
            @project.members << members
          end

          respond_to do |format|
            format.html { redirect_to_settings_in_projects }
            format.js {
              @members = members
              @member = Member.new

              ########################################################
              # Smile specific #24789 Project Leaders users activation
              # Smile comment : only if no error
              unless members.detect {|m| m.errors.any?}
                @users_activated = ''
                users_to_activate.each do |user_to_activate|
                  user_to_activate.activate!
                  debug = PluginConfig.debug
                  Rails.logger.debug "==>users #{user_to_activate.login}.activate!" if debug

                  # Smile specific : activated members for flash message
                  @users_activated += "<br/><b>#{ERB::Util.h user_to_activate.name}</b>"

                  # Smile specific : add the user to a Group configured in Plugin settings
                  if default_group_name = user_to_activate.add_to_group(PluginConfig.get_default_group_for_user(debug), debug)
                    @users_activated += ", added to GROUP : <b>#{ERB::Util.h default_group_name}</b>"
                  end
                end
              end
              # END -- Smile specific #24789 Project Leaders users activation
              ###############################################################
            }
            format.api {
              @member = members.first
              if @member.valid?
                render :action => 'show', :status => :created, :location => membership_url(@member)
              else
                render_validation_errors(@member)
              end
            }
          end
        end
      end # module AutoUserActivation
    end # module MembersOverride
  end # module Controllers
end # module Smile
