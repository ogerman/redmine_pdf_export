require_dependency "app/helpers/application_helper"

module ApplicationHelperPatch       
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do    
      unloadable # Send unloadable so it will not be unloaded in development
      alias_method_chain :parse_headings, :pdf_format
    end
  end

  module InstanceMethods
    def parse_headings_with_pdf_format(text, project, obj, attr, only_path, options)
      return if options[:headings] == false

      text.gsub!(ApplicationHelper::HEADING_RE) do
        level, attrs, content = $2.to_i, $3, $4
        item = strip_tags(content).strip
        anchor = sanitize_anchor_name(item)
        # used for single-file wiki export
        anchor = "#{obj.page.title}_#{anchor}" if options[:wiki_links] == :anchor && (obj.is_a?(WikiContent) || obj.is_a?(WikiContent::Version))
        @heading_anchors[anchor] ||= 0
        idx = (@heading_anchors[anchor] += 1)
        if idx > 1
          anchor = "#{anchor}-#{idx}"
        end
        @parsed_headings << [level, anchor, item]
        if options[:pdf_format]
          "<a name=\"#{anchor}\"></a>\n<h#{level} #{attrs}>#{content}</h#{level}>"
        else
          "<a name=\"#{anchor}\"></a>\n<h#{level} #{attrs}>#{content}<a href=\"##{anchor}\" class=\"wiki-anchor\">&para;</a></h#{level}>"
        end
      end
    end
  end


end

unless ApplicationHelper.included_modules.include? ApplicationHelperPatch
  ApplicationHelper.send(:include, ApplicationHelperPatch) 
end
