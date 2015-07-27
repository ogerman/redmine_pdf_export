module WikiExportHelper
  if Redmine::VERSION::MAJOR == 2 
    include Redmine::Export::PDF
  elsif
    include Redmine::Export::PDF::WikiPdfHelper
  end

end
