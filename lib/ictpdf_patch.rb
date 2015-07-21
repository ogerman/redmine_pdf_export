require_dependency 'lib/redmine/export/pdf'
require 'rbpdf'

module ITCPDFPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :get_image_filename, :external_url
    end
  end

  module InstanceMethods
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

Redmine::Export::PDF::ITCPDF.send(:include, ITCPDFPatch) unless Redmine::Export::PDF::ITCPDF.included_modules.include? Redmine::Export::PDF::ITCPDF
