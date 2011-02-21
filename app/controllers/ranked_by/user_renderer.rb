class RankedBy::UserRenderer < ParagraphRenderer
  include RankedByHelper

  features '/ranked_by/user_feature'

  paragraph :create_list
  paragraph :manage_list

  def create_list
    @options = paragraph_options :create_list

    js_includes
  
    render_paragraph :feature => :ranked_by_user_create_list
  end

  def manage_list
    @options = paragraph_options :manage_list

    @user = ranked_by_user

    conn_type,list_id = page_connection(:list_id)

    if editor?
      @list = RankedByList.first || RankedByList.new
    else
      @list = @user.get_list(list_id)
    end

    js_includes
    html_include(:extra_head_html,"<script>RankedBy.listId = '#{@list.id}';</script>")

    render_paragraph :feature => :ranked_by_user_manage_list
  end


  def js_includes
    require_js('http://ajax.googleapis.com/ajax/libs/jquery/1.5.0/jquery.min.js');
    require_js('http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js');
    require_js('/components/ranked_by/js/ranked_by.js');
  end

end
