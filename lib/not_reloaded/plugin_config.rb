# Plugin Config : store specific plugin configuration

class PluginConfig
  def self.get_default_group_for_user
    user_group_name = Setting.plugin_redmine_smile_auto_user_activation['assign_newly_activated_user_to_group']

    return nil if user_group_name.blank?

    if defined?(@@user_group)
      if @@user_group_name != user_group_name
        @@user_group_name = user_group_name
        @@user_group = nil
      end
    else
      @@user_group_name = user_group_name
    end

    @@user_group ||= Group.find_by_lastname(@@user_group_name)

    @@user_group
  end
end
