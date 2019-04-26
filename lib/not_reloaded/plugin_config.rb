# Plugin Config : store specific plugin configuration

class PluginConfig
  def self.get_default_group_for_user(debug=false)
    user_group_name = self.user_default_group_name

    Rails.logger.info "==>auto_user_activation get_default_group_for_user, user_group_name=[#{user_group_name}]" if debug

    return nil if user_group_name.blank?

    if defined?(@@user_group)
      if @@user_group_name != user_group_name
        Rails.logger.info " =>auto_user_activation get_default_group_for_user, #{@@user_group_name} -> #{user_group_name}" if debug
        @@user_group_name = user_group_name
        @@user_group = nil
      end
    else
      @@user_group_name = user_group_name
    end

    @@user_group ||= Group.find_by_lastname(@@user_group_name)

    if @@user_group.nil?
      Rails.logger.info " =>auto_user_activation get_default_group_for_user, group not found" if debug
    else
      Rails.logger.info " =>auto_user_activation get_default_group_for_user, group ##{@@user_group.id} found" if debug
    end

    @@user_group
  end

  def self.user_default_group_name
    Setting.plugin_redmine_smile_auto_user_activation['assign_newly_activated_user_to_group']
  end

  def self.debug
    Setting.plugin_redmine_smile_auto_user_activation['debug'] == '1'
  end
end
