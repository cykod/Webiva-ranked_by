class RankedBy::PageRenderer < ParagraphRenderer

  features '/ranked_by/page_feature'

  paragraph :list
  paragraph :embed

  def list
    @options = paragraph_options :list

    if editor?
      @list = RankedByList.first || RankedByList.new
      @items = @list.id ? @list.items : []
    else
      conn_type,list_id = page_connection :list_id
      @list = RankedByList.find_by_permalink list_id
      raise SiteNodeEngine::MissingPageException.new(site_node, language) unless @list
      @items = @list.items
    end
 
    render_paragraph :feature => :ranked_by_page_list
  end

  def embed
    list = RankedByList.find_by_permalink params[:path][0]
    raise SiteNodeEngine::MissingPageException.new(site_node, language) unless list
    data_paragraph :disposition => '', :type => 'text/javascript', :data => render_to_string(:partial => '/ranked_by/page/embed', :locals => {:list => list})
  end
end
