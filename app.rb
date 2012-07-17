require "rubygems"
require "sinatra"

require 'barby'

require 'barby/barcode/code_25'
require 'barby/barcode/code_128'

require 'barby/outputter/ascii_outputter'
require 'barby/outputter/html_outputter'

before do
  @outputs = ['ascii', 'html']
  @barcodes = ['code_25', 'code_128']
end

helpers do
  def show_select(f_name, items)
    @f_name = f_name
    @items = items
    erb :'_html_select'
  end

  def get_barcode_engine(barcode, code)
    barcode_engine = nil
    if barcode == 'code_25'
      barcode_engine = Barby::Code25.new(code)
    elsif barcode == 'code_128'
      barcode_engine = Barby::Code128B.new(code)
    end
    barcode_engine
  end

end


get '/' do
  erb :index
end

post '/' do
  begin
  # specified
  @code    = params[:code]
  # by
  @barcode = params[:barcode]
  # to
  @output  = params[:output]

  @barcode_engine = get_barcode_engine(@barcode, @code)

  erb :index

  rescue
  redirect '/?error'
  end
end


__END__

@@layout
<!DOCTYPE html>
<html>
  <head>
    <title>Code 2 BarCode</title>
    <meta charset="utf-8" />
  </head>
  <body>
  <%= yield %>
  <%= erb :'_footer' %>
  </body>
</html>

@@index
  <form action="/" method="post">
    Code: <input type="text" name="code" value="<%= @code || '' %>">
    <%= show_select('barcode', @barcodes) %>
    <%= show_select('output', @outputs) %>
    <input type="submit" value="Get BarCode">
  </form>

  <% if @code %>
    <%= @code %>:<br>

    <% if @output == 'ascii' %>
      <pre><%= @barcode_engine.to_ascii%></pre>
    <% elsif @output == 'html' %>
      <%= @barcode_engine.to_html %>
    <% end %>
  <% end %>


@@_html_select
  <select name="<%= @f_name %>">
    <% @items.each do |item| %>
      <option <%= 'selected' if params[@f_name].to_s == item %> value="<%= item %>"><%= item %></option>
    <% end %>
  </select>

@@_footer
  <br>
  <small>
    code2barcode
    based on <a href="https://github.com/toretore/barby">barby</a> |
    <a href="">source code</a> |
    <a href="/">home</a> |
  </small>
