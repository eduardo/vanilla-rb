require 'rubygems'

# In case we haven't upgraded Rubygems yet
unless Kernel.respond_to?(:gem)
  def gem(*args)
    require_gem(*args)
  end
end

gem 'soup', '>= 0.1.4'
require 'soup'

require 'vanilla/routes'
require 'vanilla/render'
require 'vanilla/dynasnip'

module Vanilla
  # Expects params to include
  #   :snip => the name of the snip [REQUIRED]
  #   :part => the part of the snip to show [OPTIONAL]
  #   :format => the format to render [OPTIONAL]
  #   :method => GET/POST/DELETE/PUT [OPTIONAL]
  #
  def self.present(params)
    case params[:format]
    when 'html', nil
      Render.render('system', :main_template, params, [], Render::Erb)
    when 'raw'
      Render.render(params[:snip], params[:part] || :content, params, [], Render::Raw)
    when 'text'
      Render.render_without_including_snips(params[:snip], params[:part] || :content, params, [])
    when 'edit'
      Render.render_without_including_snips('system', :edit_template, params, [], Render::Erb)
    else
      "Unknown format '#{params[:format]}'"
    end
  end
end