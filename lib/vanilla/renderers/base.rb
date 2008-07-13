require 'vanilla/app'

module Vanilla
  module Renderers
    class Base
      
      # Render a snip.
      def self.render(snip, part=:content)
        new(app).render(snip, part)
      end
      
      def self.escape_curly_braces(str)
        str.gsub("{", "&#123;").gsub("}", "&#125;")
      end
      
      attr_reader :app
    
      def initialize(app)
        @app = app
      end
      
      def self.snip_call_regexp
        %r{ \{ 
          ((?:.+(?:\\\}))?.+?) (?# match anything including escaped curly brace, between the braces)
        \} }x
      end
      
      def self.snip_call_part_regexp
        %r{
          \"(.+?)\" | (?# match anything in quotes)
            ([^,\s]+) (?# match anything split by commas or spaces)
        }x
      end
    
      # Default behaviour to include a snip's content
      def include_snips(content)
        content.gsub(Vanilla::Renderers::Base.snip_call_regexp) do
          parts = []
          $1.scan(Vanilla::Renderers::Base.snip_call_part_regexp) do |matches| 
            parts << matches.compact.first.gsub('\\}', "}")
          end
          snip_name, snip_attribute = parts.shift.split(".")
          snip_args = parts
          
          # hacky removal of quotes
          if snip_name =~ /^".*"$/
            snip_name = snip_name.gsub(/^"/, '').gsub(/"$/, '')
          end
          if snip_attribute =~ /^".*"$/
            snip_attribute = snip_attribute.gsub(/^"/, '').gsub(/"$/, '')
          end
          
          # Render the snip or snip part with the given args, and the current
          # context, but with the default renderer for that snip. We dispatch
          # *back* out to the root Vanilla.render method to do this.
          snip = Vanilla.snip(snip_name)
          if snip
            app.render(snip, snip_attribute, snip_args)
          else
            app.render_missing_snip(snip_name)
          end
        end
      end
      
      # Default rendering behaviour. Subclasses shouldn't really need to touch this.
      def render(snip, part=:content, args=[])
        prepare(snip, part, args)
        processed_text = render_without_including_snips(snip, part)
        include_snips(processed_text)
      end
      
      # Subclasses should override this to perform any actions required before
      # rendering
      def prepare(snip, part, args)
        # do nothing, by default
      end
      
      def render_without_including_snips(snip, part=:content)
        process_text(raw_content(snip, part))
      end
      
      # Handles processing the text of the content. 
      # Subclasses should override this method to do fancy text processing 
      # like markdown, or loading the content as Ruby code.
      def process_text(content)
        content
      end
      
      # Returns the raw content for the selected part of the selected snip
      def raw_content(snip, part)
        snip.__send__((part || :content).to_sym)
      end
    end
  end
end