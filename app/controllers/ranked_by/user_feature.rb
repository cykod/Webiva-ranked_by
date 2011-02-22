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
       <h2 class='edit'>${name}</h2>
       <p class='edit'>${description}</p>
    </li>
  </script>
    <cms:title/>
    <cms:author/>

    <cms:add_to_list/>
    <cms:autocomplete/>

      <cms:list/>
  FEATURE

  def ranked_by_user_manage_list_feature(data)
    webiva_feature(:ranked_by_user_manage_list,data) do |c|
      add_item_tags(c,data)

      c.define_tag('title') do |t|
        "<h1 class='edit' id='list-title'>#{h(data[:list].name || "[Enter a list title]") }</h1>"
      end

      c.define_tag('author') do |t|
        "<h2 class='edit' id='list-author'>#{h(data[:list].author || "[Author Name Here]") }</h2>"
      end

      c.value_tag('list') do |t|
        idx = 0;
        
        "<ul id='ranked_list'>" +
          data[:list].items.map { |itm|
          idx += 1;
          "<li id='item_#{itm.id}'>
           <h3>##{idx}</h3>
           <a class='image_link' href='#{itm.url}' target='_blank'><img src='#{itm.large_image_url}'/></a>
           <h2  id='item-title-#{itm.id}' class='edit'>#{h itm.name}</h2>
           <p id='item-description-#{itm.id}' class='editarea'>#{h itm.description}</p>
          </li>"
        }.join("\n") + "</ul>"
      end
    end
  end


  def add_item_tags(c,data) 
   c.define_tag('add_to_list') do |t|
        text_field(:list,:add_item, :title => 'enter an item name or url') +
        "<span id='loading-indicator' style='visibility:hidden;'><img src='/components/ranked_by/images/indicator.gif'/></span>"
      end

      c.define_tag('autocomplete') do |t|
        "<div id='add-item-autocomplete' style='display:none;'></div>"
      end

  end

end
