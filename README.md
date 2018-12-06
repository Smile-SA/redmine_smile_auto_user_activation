redmine_smile_auto_user_activation
==================================

Redmine plugin that adds the hability to auto enable new users, the first time they are added in a project.

Not yet activated users are available in add Members to Project popup.
A notice message is added when user(s) have been activated.

## How it works

* Overrides the Members create action
* Overrides the Members render_principals_for_new_members helper
* Rewrites Members create.js.erb view

## Personnalise not yet activated users color

It is higlhy suggested to give them a specific color in :
**public/stylesheets/application.css** or in your theme specific css file

```css
#principals label.status-2 a {
	color: #8F9C9C;
}
```

Enjoy !
