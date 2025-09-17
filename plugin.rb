# frozen_string_literal: true

# name: discourse-my-plugin
# about: Plugin with modal forms
# version: 1.0.0
# authors: Your Name
# url: https://github.com/username/discourse-my-plugin

enabled_site_setting :my_plugin_enabled

# Register assets
register_asset 'stylesheets/common/main.scss'
register_asset 'stylesheets/mobile/main.scss', :mobile

# Register SVG icons for toolbar buttons
register_svg_icon "fas-plus-circle" if respond_to?(:register_svg_icon)
register_svg_icon "fas-edit" if respond_to?(:register_svg_icon)

# Extend CSP for external resources if needed
extend_content_security_policy(
  script_src: %w[https://cdn.example.com],
  style_src: %w[https://cdn.example.com]
)

after_initialize do
  # Add custom routes for AJAX endpoints
  Discourse::Application.routes.append do
    namespace :my_plugin, defaults: { format: :json } do
      resources :forms, only: [:create, :show, :update]
    end
  end
  
  # Register custom fields
  register_post_custom_field_type('my_plugin_data', :json)
end
