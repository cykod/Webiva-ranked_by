class RankedBy::PageController < ParagraphController
  editor_header 'Ranked By Paragraphs'
  
  editor_for :most_popular, :name => 'Most Popular', :feature => :ranked_by_page_most_popular

  class MostPopularOptions < HashModel
    attributes :limit => 10, :list_page_id => nil, :expires => 5, :created_ago => 10
    
    page_options :list_page_id
    integer_options :limit, :expires, :created_ago

    validates_presence_of :list_page_id

    options_form(
                 fld(:list_page_id, :page_selector),
                 fld(:expires, :text_field, :unit => 'minutes'),
                 fld(:created_ago, :text_field, :unit => 'minutes', :description => 'fetch list from X minutes ago'),
                 fld(:limit, :text_field)
                 )
  end
end
