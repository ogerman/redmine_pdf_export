require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'ictpdf_patch'
  require_dependency 'local_resource'
end

Redmine::Plugin.register :pdf_export do
  name 'Pdf Export plugin'
  author 'Oleg German'
  description 'Extends PDF export functionality'
  version '0.0.1'
  url 'https://github.com/ogerman/redmine_pdf_export'
  author_url 'https://github.com/ogerman'
  settings :default => { :enable_external_images => false}, :partial => 'settings/settings'
end
