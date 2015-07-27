require_dependency "#{Rails.root}/lib/redmine/export/pdf"
require 'rbpdf'

module ITCPDFPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :get_image_filename, :external_url
      alias_method_chain :Footer, :options
      alias_method_chain :RDMwriteHTMLCell, :backport if Redmine::VERSION::MAJOR == 2
    end
  end

  module InstanceMethods


    if Redmine::VERSION::MAJOR == 2
      def RDMwriteFormattedCell(w, h, x, y, txt='', attachments=[], border=0, ln=1, fill=0)
        @attachments = attachments

        css_tag = ' <style>
        table, td {
          border: 2px #ff0000 solid;
        }
        th {  background-color:#EEEEEE; padding: 4px; white-space:nowrap; text-align: center;  font-style: bold;}
        pre {
          background-color: #fafafa;
        }
        </style>'

        # Strip {{toc}} tags
        txt.gsub!(/<p>\{\{([<>]?)toc\}\}<\/p>/i, '')
        writeHTMLCell(w, h, x, y, css_tag + txt, border, ln, fill)
      end

      def RDMwriteHTMLCell_with_backport(w, h, x, y, txt='', attachments=[], border=0, ln=1, fill=0)
        txt = formatted_text(txt)
        RDMwriteFormattedCell(w, h, x, y, txt, attachments, border, ln, fill)
      end
    end
    
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
