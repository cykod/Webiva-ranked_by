class RankedBy::PageController < ParagraphController
  editor_header 'Ranked By Paragraphs'
  
  editor_for :list, :name => "Display List", :feature => :ranked_by_page_list, :inputs => { :list_id => [[ :url, 'List Identifier', :path ]] }

  class ListOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil

    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end
end
