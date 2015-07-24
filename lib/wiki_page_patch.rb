require_dependency 'wiki_page'

module WikiPagePatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
    end
  end

  module InstanceMethods
    def linked_pages
      self.content.linked_pages.delete_if {|lp| !self.children.include?(lp) }
    end

    def recursive_linked_pages( omit_pages = [])
      if omit_pages.include?(self)
         []
      else
         omit_pages.push(self)
         [self] | linked_pages.map { |lp| lp.recursive_linked_pages(omit_pages) }.flatten
      end
    end
  end
end

WikiPage.send(:include, WikiPagePatch) unless WikiPage.included_modules.include? WikiPagePatch
