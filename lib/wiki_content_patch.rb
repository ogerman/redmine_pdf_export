require_dependency 'wiki_content'

module WikiContentPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end

  module InstanceMethods
    def linked_pages
      text.scan(/(!)?(\[\[([^\]\n\|]+)(\|([^\]\n\|]+))?\]\])/).map do |m|
        esc = m[0]
        page = m[2]

        if esc.nil?
          if page =~ /^([^\:]+)\:(.*)$/
            page = $2
          end

          # extract anchor
          if page =~ /^(.+?)\#(.+)$/
            page = $1
          end
          # check if page exists
          project.wiki.find_page(page)
        end
      end
    end
  end
end

WikiContent.send(:include, WikiContentPatch) unless WikiContent.included_modules.include? WikiContentPatch
