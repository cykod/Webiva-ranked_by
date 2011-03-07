class RankedBy::PageFeature < ParagraphFeature

  feature :ranked_by_page_list, :default_feature => <<-FEATURE
  <cms:list>
    <h1><cms:name/></h1>
    <p><cms:description/></p>
  </cms:list>
  FEATURE

  def ranked_by_page_list_feature(data)
    webiva_feature(:ranked_by_page_list,data) do |c|
      c.expansion_tag('list') { |t| t.locals.list = data[:list] }
      self.add_list_tags c, data
    end
  end

  def add_list_tags(c, data)
    c.h_tag('list:name') { |t| t.locals.list.name }
    c.h_tag('list:description') { |t| t.locals.list.description }
    c.h_tag('list:author') { |t| t.locals.list.author }
    c.date_tag('list:created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.list.created_at }
    c.value_tag('list:created_ago') { |t| time_ago_in_words(t.locals.list.created_at) }
  end
end
