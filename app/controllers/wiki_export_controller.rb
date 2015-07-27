class WikiExportController < ApplicationController
  unloadable

  default_search_scope :wiki_pages
  before_filter :find_wiki, :authorize
  before_filter :find_existing_page, :only => [:toc]

  helper :attachments
  include AttachmentsHelper
  helper :watchers

  include Redmine::Export::PDF

  def toc
    page = @wiki.find_page(params[:id])
    @pages = @page.recursive_linked_pages
    respond_to do |format|
      format.html {
        export = render_to_string :action => 'export_multiple', :layout => false
        send_data(export, :type => 'text/html', :filename => "#{page.title}.html")
      }
      format.pdf {
        send_file_headers! :type => 'application/pdf', :filename => "#{@page.title}.pdf"
      }
    end
  end

private

  def find_wiki
    @project = Project.find(params[:project_id])
    @wiki = @project.wiki
    render_404 unless @wiki
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Finds the requested page and returns a 404 error if it doesn't exist
  def find_existing_page
    @page = @wiki.find_page(params[:id])
    if @page.nil?
      render_404
      return
    end
    if @wiki.page_found_with_redirect?
      redirect_to_page @page
    end
  end
end
