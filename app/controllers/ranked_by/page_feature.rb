class RankedBy::PageFeature < ParagraphFeature

  include ActionView::Helpers::DateHelper

  feature :ranked_by_page_most_popular, :default_feature => <<-FEATURE
  <cms:most_viewed>
  <cms:lists>
  <ul>
    <cms:list>
    <li>
      <cms:list_link><cms:name/></cms:list_link>
   </li>
   </cms:list>
  </ul>
  </cms:lists>
  </cms:most_viewed>

  <cms:most_recent>
  <cms:lists>
  <ul>
    <cms:list>
    <li>
      <cms:list_link><cms:name/></cms:list_link>
   </li>
   </cms:list>
  </ul>
  </cms:lists>
  </cms:most_recent>
  FEATURE

  def ranked_by_page_most_popular_feature(data)
    webiva_feature(:ranked_by_page_most_popular,data) do |c|
      c.expansion_tag('most_viewed') { |t| data[:most_viewed] }
      c.loop_tag('most_viewed:list') { |t| data[:most_viewed] }
      c.expansion_tag('most_recent') { |t| data[:most_recent] }
      c.loop_tag('most_recent:list') { |t| data[:most_recent] }
      self.add_list_tags c, data
    end
  end

  def add_list_tags(c, data)
    c.h_tag('list:name') { |t| t.locals.list.name || 'Not set' }
    c.h_tag('list:description') { |t| t.locals.list.description }
    c.h_tag('list:author') { |t| t.locals.list.author }
    c.link_tag('list:list') { |t| data[:options].list_page_node.link(t.locals.list.permalink) if data[:options].list_page_node }
    c.value_tag('list:views') { |t| t.locals.list.views }
    c.value_tag('list:num_items') { |t| t.locals.list.num_items }
    c.date_tag('list:created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.list.created_at }
    c.value_tag('list:created_ago') { |t| time_ago_in_words(t.locals.list.created_at) }
    
    c.loop_tag('list:item') { |t| t.locals.list.items }
    self.add_item_tags c, data
  end
  
  def add_item_tags(c, data)
    c.h_tag('list:item:name') { |t| t.locals.item.name }
    c.h_tag('list:item:description') { |t| t.locals.item.description }
    c.value_tag('list:item:source') { |t| t.locals.item.source_domain }
    c.link_tag('list:item:item') { |t| t.locals.item.url }
    c.value_tag('list:item:small_image_url') { |t| t.locals.item.small_image_url }
    c.value_tag('list:item:large_image_url') { |t| t.locals.item.large_image_url }
    c.define_tag('list:item:small_image') { |t| tag('img', t.attr.merge({:src => t.locals.item.small_image_url}), false, false) if t.locals.item.small_image_url }
    c.define_tag('list:item:large_image') { |t| tag('img', t.attr.merge({:src => t.locals.item.large_image_url}), false, false) if t.locals.item.large_image_url }
    c.image_tag('list:item:image') { |t| t.locals.item.image_file }
    c.value_tag('list:item:ranking') { |t| t.locals.item.ranking }
    c.date_tag('list:item:created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.item.created_at }
    c.value_tag('list:item:created_ago') { |t| time_ago_in_words(t.locals.item.created_at) }
  end
end
