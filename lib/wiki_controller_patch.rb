require_dependency 'wiki_controller'

module WikiControllerPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :show, :new_pdf_export
    end
  end

  module InstanceMethods
    def show_with_new_pdf_export
      if params[:version] && !User.current.allowed_to?(:view_wiki_edits, @project)
        deny_access
        return
      end
      @content = @page.content_for_version(params[:version])
      if @content.nil?
        if User.current.allowed_to?(:edit_wiki_pages, @project) && editable? && !api_request?
          edit
          render :action => 'edit'
        else
          render_404
        end
        return
      end
      if User.current.allowed_to?(:export_wiki_pages, @project)
        if params[:format] == 'pdf'
          send_file_headers! :type => 'application/pdf', :filename => "#{@page.title}.pdf"
          return
        elsif params[:format] == 'html'
          export = render_to_string :action => 'export', :layout => false
          send_data(export, :type => 'text/html', :filename => "#{@page.title}.html")
          return
        elsif params[:format] == 'txt'
          send_data(@content.text, :type => 'text/plain', :filename => "#{@page.title}.txt")
          return
        end
      end
      @editable = editable?
      @sections_editable = @editable && User.current.allowed_to?(:edit_wiki_pages, @page.project) &&
        @content.current_version? &&
        Redmine::WikiFormatting.supports_section_edit?

      respond_to do |format|
        format.html
        format.api
      end
    end
  end
end

unless WikiController.included_modules.include?(WikiControllerPatch)
  WikiController.send(:include, WikiControllerPatch)
end
