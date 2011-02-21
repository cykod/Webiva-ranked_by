class RankedBy::UserFeature < ParagraphFeature

  feature :ranked_by_user_create_list, :default_feature => <<-FEATURE
    <cms:add_to_list/>
    <cms:autocomplete/>
  FEATURE

  def ranked_by_user_create_list_feature(data)
    webiva_feature(:ranked_by_user_create_list,data) do |c|
      add_item_tags(c,data)
    end
  end

  feature :ranked_by_user_manage_list, :default_feature => <<-FEATURE
  <script id="itemTemplate" type="text/x-jquery-tmpl"> 
    <li id='item_${id}'>
       <h2>${name}</h2>
       <p>${description}</p>
    </li>
  </script>

    <cms:add_to_list/>
    <cms:autocomplete/>
    <cms:list/>
  FEATURE

  def ranked_by_user_manage_list_feature(data)
    webiva_feature(:ranked_by_user_manage_list,data) do |c|
      add_item_tags(c,data)

      c.value_tag('list') do |t|
        "<ul id='ranked_list'>" +
          data[:list].items.map { |itm|
          "<li id='item_#{itm.id}'>
           <h2>#{h itm.name}</h2>
           <p>#{h itm.description}</p>
          </li>"
        }.join("\n") + "</ul>"
      end
    end
  end


  def add_item_tags(c,data) 
   c.define_tag('add_to_list') do |t|
        text_field(:list,:add_item)
      end

      c.define_tag('autocomplete') do |t|
        "<div id='add_item_autocomplete' style='display:none;'></div>"
      end

  end

end
