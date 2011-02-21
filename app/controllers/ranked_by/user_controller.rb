class RankedBy::UserController < ParagraphController
  include RankedByHelper

  editor_header 'Ranked By Paragraphs'
  
  editor_for :create_list, :name => "Create list", :feature => :ranked_by_user_create_list
  editor_for :manage_list, :name => "Manage list", :feature => :ranked_by_user_manage_list, :inputs => { :list_id => [[ :url, 'List Identifier', :path ]] }

  user_actions :lookup, :create_list_add_item, :add_item

  class CreateListOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil

    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end

  class ManageListOptions < HashModel
    # Paragraph Options
    # attributes :success_page_id => nil

    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end


  def lookup
    @user = ranked_by_user

    @results = @user.lookup(params[:value])

    render :partial => '/ranked_by/user/lookup', :locals => { :results => @results }
  end

  def create_list_add_item
    @user = ranked_by_user

    list = @user.create_list
    list.add_item(@user.lookup_by_identifier(params[:identifier]))

    render :json => list
  end

  def add_item
    @user = ranked_by_user

    list = @user.get_list_by_id(params[:list_id])

    list.add_item(@user.lookup_by_identifier(params[:identifier]))

    render :json => list
  end

end
