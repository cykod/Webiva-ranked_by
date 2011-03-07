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
        "<h1 #{"class='edit'" if data[:editable]} id='list-title'>#{h(data[:list].name || "[Enter a list title]") }</h1>"
      end

      c.define_tag('author') do |t|
        "<h2 #{"class='edit'" if data[:editable]} id='list-author'>#{h(data[:list].author || "[Author Name Here]") }</h2>"
      end

      c.value_tag('list') do |t|
        idx = 0;
        
        "<ul id='ranked_list'>" +
          data[:list].items.map { |itm|
          idx += 1;
          render_to_string :partial => '/ranked_by/user/item', :locals => {:item => itm, :index => idx, :editable => data[:editable] }
        }.join("\n") + "</ul>"
      end
    end
  end

  feature :ranked_by_user_my_lists, :default_feature => <<-FEATURE
  <cms:lists>
  <ul>
    <cms:list>
    <li>
      <cms:manage_link><cms:name/></cms:manage_link>
    </li>
    </cms:list>
  </ul>
  </cms:lists>
  FEATURE

  def ranked_by_user_my_lists_feature(data)
    webiva_feature(:ranked_by_user_my_lists, data) do |c|
      c.loop_tag('list') { |t| data[:lists] }
      c.h_tag('list:name') { |t| t.locals.list.name }
      c.link_tag('list:manage') { |t| data[:options].manage_list_page_node(t.locals.list.permallink) if data[:options].manage_list_page_node }
    end
  end

  def add_item_tags(c,data) 
   c.define_tag('add_to_list') do |t|
     if data[:editable]
        text_field(:list,:add_item, :title => 'enter an item name or url') +
        "<span id='loading-indicator' style='visibility:hidden;'><img src='/components/ranked_by/images/indicator.gif'/></span>"
     else
       ""
     end
      end


      c.define_tag('autocomplete') do |t|
        if data[:editable]
        "<div id='add-item-autocomplete' style='display:none;'></div>"
        else
          ""
        end

      end

  end

end
