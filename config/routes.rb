RedmineApp::Application.routes.draw do
  match 'projects/:project_id/wiki/:id/toc(.:format)', :to => 'wiki_export#toc', :via => 'get', as: 'wiki_export_as_toc'
end
