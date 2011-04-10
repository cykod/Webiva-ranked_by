class RankedBy::UserRenderer < ParagraphRenderer
  include RankedByHelper

  features '/ranked_by/user_feature'

  paragraph :create_list
  paragraph :manage_list
  paragraph :my_lists

  def create_list
    @options = paragraph_options :create_list

    js_includes
    @editable = true
  
    render_paragraph :feature => :ranked_by_user_create_list
  end

  def manage_list
    @options = paragraph_options :manage_list
    @options.manage_list_page_id = site_node.id

    @user = ranked_by_user

    conn_type,list_id = page_connection(:list_id)

    if editor?
      @list = RankedByList.first || RankedByList.new
    else
      @list = @user.get_list(list_id)
    end

    if !@list
      @list = RankedByList.find_by_permalink(list_id)
      require_js('http://ajax.googleapis.com/ajax/libs/jquery/1.5.0/jquery.min.js');
      @editable = false
      if @list
        increment_list_views @list
        @list.must_refresh
      end
    else
      js_includes
      @editable = true

      if request.post? && params[:list] && ! editor?
        if params[:permalink]
          @list.generate_permalink
          @list.save
          redirect_paragraph site_node.link(@list.permalink)
          return
        end
      end
    end

    set_title(@list.name) unless @list.name.blank?

    html_include(:extra_head_html,"<script>RankedBy.listId = '#{@list.id}';RankedBy.permalink = '#{@list.permalink}';</script>")

    render_paragraph :feature => :ranked_by_user_manage_list
  end

  def my_lists
    @options = paragraph_options :my_lists

    @user = ranked_by_user
    
    if request.post? && params[:list]
      if params[:delete]
        list = @user.ranked_by_lists.find_by_permalink(params[:list][:permalink])
        list.delete if list
        redirect_paragraph :page
        return
      end
    end

    @lists = @user.ranked_by_lists.all(:order => 'created_at DESC')
    render_paragraph :feature => :ranked_by_user_my_lists
  end

  def js_includes
    require_js('http://ajax.googleapis.com/ajax/libs/jquery/1.5.0/jquery.min.js');
    require_js('http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js');
    require_js('https://ajax.googleapis.com/ajax/libs/jqueryui/1.8.9/jquery-ui.min.js');
    require_js('/components/ranked_by/js/jquery.jeditable.js');
    require_js('/components/ranked_by/js/ranked_by.js');
    require_js('/components/ranked_by/js/jquery.labelify.js');
    require_js('/components/ranked_by/js/jquery.scrollto-1.4.2-min.js');
    require_js('/components/ranked_by/js/jquery.localscroll-1.2.7-min.js');
  end
end
