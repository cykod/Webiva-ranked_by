class RankedBy::EmbedDispatcher < ModuleDispatcher

  available_pages ['/', 'embed', 'Embed Ranked By List', 'Embed Ranked By List', false]

  def embed(args)
    simple_dispatch(1, 'ranked_by/page', 'embed', :data => @site_node.page_modifier.modifier_data)
  end
end
