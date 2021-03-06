if Redmine::VERSION::MAJOR == 2
#  require_dependency "#{Rails.root}/lib/redmine/export/pdf"
elsif
  require_dependency "#{Rails.root}/lib/redmine/export/pdf/wiki_pdf_helper"
end

module WikiPdfHelperPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :write_wiki_page, :optional_attachments_footer
    end
  end

  module InstanceMethods
    def write_wiki_page_with_optional_attachments_footer(pdf, page)
      text = textilizable(page.content, :text,
        :only_path => false,
        :edit_section_links => false,
#        :headings => false,
        :inline_attachments => false,
        :pdf_format => true,
        :wiki_links => :anchor
      )
      text = "<style>#{Setting.plugin_pdf_export['pdf_css']}</style> \n #{text}"
      text = "<a name=\"#{page.title}\"></a> \n #{text}"
      pdf.RDMwriteFormattedCell(190,5,'','', text, page.attachments, 0)
      if !Setting.plugin_pdf_export['disable_attachments_footer'] && page.attachments.any?
        pdf.ln(5)
        pdf.SetFontStyle('B',9)
        pdf.RDMCell(190,5, l(:label_attachment_plural), "B")
        pdf.ln
        for attachment in page.attachments
          pdf.SetFontStyle('',8)
          pdf.RDMCell(80,5, attachment.filename)
          pdf.RDMCell(20,5, number_to_human_size(attachment.filesize),0,0,"R")
          pdf.RDMCell(25,5, format_date(attachment.created_on),0,0,"R")
          pdf.RDMCell(65,5, attachment.author.name,0,0,"R")
          pdf.ln
        end
      end
    end

    def wiki_pages_array_to_pdf(pages, project)
      pdf = Redmine::Export::PDF::ITCPDF.new(current_language)
      pdf.set_title(project.name)
      pdf.alias_nb_pages
      pdf.footer_date = format_date(Date.today)
      pdf.add_page
      # Set resize image scale
      pdf.set_image_scale(1.6)
      pdf.SetFontStyle('',9)
      write_page_hierarchy(pdf, {nil => pages})
      pdf.output
    end
  end
end
if Redmine::VERSION::MAJOR == 2
  unless Redmine::Export::PDF.included_modules.include? WikiPdfHelperPatch
    Redmine::Export::PDF.send(:include, WikiPdfHelperPatch)
    WikiHelper.send(:include, Redmine::Export::PDF)
  end
elsif Redmine::VERSION::MAJOR == 3
  unless Redmine::Export::PDF::WikiPdfHelper.included_modules.include? WikiPdfHelperPatch
    Redmine::Export::PDF::WikiPdfHelper.send(:include, WikiPdfHelperPatch) 
  end
end

