require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'ictpdf_patch'
  require_dependency 'local_resource'
  require_dependency 'wiki_pdf_helper_patch'
  require_dependency 'wiki_content_patch'
  require_dependency 'wiki_page_patch'
  require_dependency 'application_helper_patch'
  require_dependency 'comment_macro'
  if Redmine::VERSION::MAJOR == 2
    require_dependency 'wiki_controller_patch'
  end

end

Redmine::Plugin.register :pdf_export do
  name 'Pdf Export plugin'
  author 'Oleg German'
  description 'Extends PDF export functionality'
  version '0.1'
  url 'https://github.com/ogerman/redmine_pdf_export'
  author_url 'https://github.com/ogerman'
  settings :default => {
    :enable_external_images => false,
    :disable_attachments_footer => false,
    :footer_with_page_number_only => false,
    :pdf_css => ''
  }, :partial => 'settings/settings'
  project_module :pdf_export do
    permission :export_wiki_as_toc, { wiki_export: [:toc] }, :read => true
  end
end
