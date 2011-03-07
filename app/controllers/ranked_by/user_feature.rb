class RankedBy::UserFeature < ParagraphFeature

  include ActionView::Helpers::DateHelper

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
      <cms:manage_link><cms:name/></cms:manage_link> <cms:delete/>
      <cms:embed_code><textarea readonly><cms:value/></textarea></cms:embed_code>
    </li>
    </cms:list>
  </ul>
  </cms:lists>
  FEATURE

  def ranked_by_user_my_lists_feature(data)
    webiva_feature(:ranked_by_user_my_lists, data) do |c|
      c.loop_tag('list') { |t| data[:lists] }
      self.add_list_tags c, data
      c.define_tag('list:delete') do |t|
        confirm_message =  t.attr['confirm_message'] || 'Are you sure you want to delete this list?'
        label = t.attr['label'] || 'Delete'
        form_tag("") +
          tag(:input, :type => 'hidden', :name => 'list[permalink]',:value => t.locals.list.permalink) + 
          tag(:input, :type => 'hidden', :name => 'delete', :value => '1') + 
          tag(:input, :type => 'submit', :value => label, :class => t.attr['class'], :id => t.attr['id'], :style => t.attr['style'],
              :onclick => "if(confirm('#{jvh confirm_message}')) { this.form.submit(); return true; } else { return false; }") + 
          "</form>"
      end
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
  
  def add_list_tags(c, data)
    c.h_tag('list:name') { |t| t.locals.list.name }
    c.h_tag('list:description') { |t| t.locals.list.description }
    c.h_tag('list:author') { |t| t.locals.list.author }
    c.link_tag('list:manage') { |t| data[:options].manage_list_page_node.link(t.locals.list.permalink) if data[:options].manage_list_page_node }
    c.link_tag('list:list') { |t| data[:options].list_page_node.link(t.locals.list.permalink) if data[:options].list_page_node }
    c.link_tag('list:embed') { |t| data[:options].embed_page_node.link(t.locals.list.permalink) if data[:options].embed_page_node }
    c.h_tag('list:embed_code') do |t|
      if data[:options].list_page_node && data[:options].embed_page_node
        name = t.locals.list.name
        permalink = t.locals.list.permalink
        list_url = data[:options].list_page_node.domain_link permalink
        embed_url = data[:options].embed_page_node.domain_link permalink
 
        "<a id=\"ranked_by_#{permalink}\" target=\"_blank\" href=\"#{list_url}\">#{name}</a>\n<script src=\"#{embed_url}\" type=\"text/javascript\"></script>"
      end
    end
    c.value_tag('list:views') { |t| t.locals.list.views }
    c.value_tag('list:num_items') { |t| t.locals.list.num_items }
    c.date_tag('list:created_at',DEFAULT_DATETIME_FORMAT.t) { |t| t.locals.list.created_at }
    c.value_tag('list:created_ago') { |t| time_ago_in_words(t.locals.list.created_at) }
  end
end
