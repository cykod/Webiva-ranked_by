class RankedBy::PageRenderer < ParagraphRenderer

  features '/ranked_by/page_feature'

  paragraph :embed

  def embed
    list = RankedByList.find_by_permalink params[:path][0]
    raise SiteNodeEngine::MissingPageException.new(site_node, language) unless list
    data_paragraph :disposition => '', :type => 'text/javascript', :data => render_to_string(:partial => '/ranked_by/page/embed', :locals => {:list => list})
  end
end
