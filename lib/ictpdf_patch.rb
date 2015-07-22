require_dependency 'lib/redmine/export/pdf'
require 'rbpdf'

module ITCPDFPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :get_image_filename, :external_url
      alias_method_chain :Footer, :options
    end
  end

  module InstanceMethods

    def Footer_with_options
      set_text_color #Reset to black
      set_font(@font_for_footer, 'I', 8)
      unless Setting.plugin_pdf_export['footer_with_page_number_only']
        set_x(15)
        if get_rtl
          RDMCell(0, 5, @footer_date, 0, 0, 'R')
        else
          RDMCell(0, 5, @footer_date, 0, 0, 'L')
        end
      end


      if Setting.plugin_pdf_export['footer_with_page_number_only']
        set_x(-10)
        RDMCell(0, 5, get_alias_num_page(), 0, 0, 'C')
      else 
        set_x(-30)
        RDMCell(0, 5, get_alias_num_page() + '/' + get_alias_nb_pages(), 0, 0, 'C')
      end
    end

    def get_image_filename_with_external_url(attrname)
      atta = Redmine::Export::PDF::RDMPdfEncoding.attach(@attachments, attrname, "UTF-8")
      if atta
        return atta.diskfile
      else
        if Setting.plugin_pdf_export['enable_external_images']
          attrname_utf8 = Redmine::CodesetUtil.to_utf8(attrname, "UTF-8")
          return LocalResource.tmp_file_path(attrname_utf8, /(image\/gif|image\/jpeg|image\/png)/)
        else
          nil
        end
      end
    end
  end
end

Redmine::Export::PDF::ITCPDF.send(:include, ITCPDFPatch) unless Redmine::Export::PDF::ITCPDF.included_modules.include? ITCPDFPatch
