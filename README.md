redmine_smile_auto_user_activation
==================================

Redmine plugin that adds the hability to **auto enable new users**, the **first time** they are **added in a project**.

Not yet activated users will be available in **Add Members to Project** popup.
A notice message is added when user(s) have been activated.
Optionally a **default group** can be assigned to them.
A debug option is available in the plugin settings to add traces in the Rails log file.

# How it works

* Not yet activated users are now available in the Add Members popup :

<kbd>![alt text](https://github.com/Smile-SA/redmine_smile_auto_user_activation/blob/master/documentation/redmine_smile_auto_user_to_activate.png "Not yet enabled users are available in the Add Members popup")</kbd>

* When validating the new users, a **notice message** is added for the users that have just been activated :

<kbd>![alt text](https://github.com/Smile-SA/redmine_smile_auto_user_activation/blob/master/documentation/redmine_smile_auto_user_activated.png "A Notice message is added for the users that just have been activated")</kbd>
 
* The notice tells if the user was added to the **default group**, if it was configured in the plugins settings :

<kbd>![alt text](https://github.com/Smile-SA/redmine_smile_auto_user_activation/blob/master/documentation/add_to_default_group.png "The Notice tells if the user was added to the default group")</kbd>

# How it is implemented

## 🔑 Overrides the Members create action

* 🔑 Members Controller action **create**

  Activate users when added to project, if **no error**  
  Generate a **flash message** to indicate which users have been activated  
  **Optionally** : if group name set in plugin settings, add newly activated users **to a group**

* 🔑 Members View **app/views/members/create.js.erb**

## Overrides Helpers

* Application Helper

  - 🔑 Method **principals_check_box_tags**

    New link option to have link on user, status class added

* Groups Helper

  🔑 Method **render_principals_for_new_group_users**, added link param value

* Members Helper

  - 🔑 Method **render_principals_for_new_members helper**

    Users listed : active -> active_or_to_activate  
    Link to user enabled  
    Grey color for users to activate (3rd param = true)

* Users Helper

  🔑 Method **change_status_link**, add an un-activate link

## Augment Principal Model

  * New scopes **active_or_to_activate**, **visible_any_status**
  * New method **add_to_group**

### New Tools in lib/not_reloaded

* New **smile_tools.rb**

  Methods to trace **overrides made by Smile plugins**, overrides listed in plugin settings
  * **trace_by_line**
  * **trace_override**
  * **regex_path_in_plugin**

  Method to debug a scope : **debug_scope**

* New **plugin_config.rb**

  Method **get_default_group_for_user** to cache the **Group** to add to the newly activated users

# You have to Personnalise not yet activated users color

It is higlhy suggested to give them a specific color in :
**public/stylesheets/application.css** or in your theme specific css file

```css
#principals label.status-2 a {
  color: #8F9C9C;
}
```

# Changelog

* **V1.0.4**  Enforce override of MembersController.create

  Trigger an exception that prevents application to start if override fails

* **V1.0.3** New option to add debug traces in Rails log file
* **V1.0.2** New option to add user in a default group
* **V1.0.0** Initial version


Enjoy !

<kbd>![alt text](https://compteur-visites.ennder.fr/sites/35/token/githubaua/image "Logo") <!-- .element height="10%" width="10%" --></kbd>
