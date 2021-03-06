class RankedBy::PageRenderer < ParagraphRenderer
  include RankedByHelper
  
  features '/ranked_by/page_feature'

  paragraph :most_popular
  paragraph :embed

  def embed
    list = RankedByList.find_by_permalink params[:path][0]
    raise SiteNodeEngine::MissingPageException.new(site_node, language) unless list
    increment_list_views list
    data_paragraph :disposition => '', :type => 'text/javascript', :data => render_to_string(:partial => '/ranked_by/page/embed', :locals => {:list => list})
  end
  
  def most_popular
    @options = paragraph_options :most_popular
    
    result = renderer_cache(nil, nil, :expires => @options.expires*60) do |cache|
      limit = @options.limit
      @most_viewed = RankedByList.all :conditions => 'name IS NOT NULL && name != ""', :order => 'views DESC', :limit => limit
      @most_recent = RankedByList.all :conditions => ['name IS NOT NULL && name != "" && created_at < ?', @options.created_ago.minutes.ago], :order => 'created_at DESC', :limit => limit
      cache[:output] = ranked_by_page_most_popular_feature
    end

    render_paragraph :text => result.output
  end
end
