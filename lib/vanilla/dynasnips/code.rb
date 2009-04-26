require 'vanilla/dynasnip'
require 'syntax/convertors/html'

class CodeHighlighter < Dynasnip
  snip_name "code"
  
  def handle(language, snip_to_render, part_to_render='content')
    snip = Vanilla.snip(snip_to_render)
    text = snip.__send__(part_to_render.to_sym)
    convertor = Syntax::Convertors::HTML.for_syntax(language)
    code = convertor.convert(text, false)
    %(<span class="code ) + language + %("><code>) + code + %(</code></span>)
  end

  self
end