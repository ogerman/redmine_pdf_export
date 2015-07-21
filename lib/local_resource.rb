require_dependency 'app/models/attachment'

class LocalResource

  require 'open-uri'
  attr_reader :uri, :content_type
  
  def initialize(uri, content_type = nil)
    @uri = uri
    @content_type = content_type
  end
 
  def file
    @file ||= Tempfile.new(tmp_filename, tmp_folder, encoding: encoding).tap do |f|
      io.rewind
      f.write(io.read)
      f.close
    end
  end
 
  def io
    @io ||= uri.open
    if @content_type.present? && @io.meta['content-type'] !~ @content_type
       raise "invalid content type"
    end
    @io
  end
 
  def encoding
    io.rewind
    io.read.encoding
  end
 
  def tmp_filename
    [
      Pathname.new(uri.path).basename,
      Pathname.new(uri.path).extname
    ]
  end
 
  def tmp_folder
    Rails.root.join('tmp')
  end

  def self.tmp_file_path(uri, mime_regexp = nil)
    uri_obj = URI.parse(uri)
    if uri_obj.host == Setting['host_name'] || uri_obj.relative?
      id = uri_obj.path.match(/attachments\/((download|thumbnail)\/)?(?<id>\d*)/).try(:[], :id)
      if id.present? && attachment = Attachment.find(id)
        return attachment.diskfile if attachment.visible?
      end
    end

    #Add protocol and schema to url and reinit (to make open method availible)
    uri_obj.host = Setting['host_name'] if uri_obj.host.blank?
    uri_obj.scheme = Setting['protocol'] if uri_obj.scheme.blank?
    uri_obj = URI.parse(uri_obj.to_s)
    

    self.new(uri_obj, mime_regexp).file.path
  rescue => e
    Rails.logger.error(e.message)
    nil
  end
end
