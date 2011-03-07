class RankedBy::UserController < ParagraphController
  include RankedByHelper

  editor_header 'Ranked By Paragraphs'
  
  editor_for :create_list, :name => "Create list", :feature => :ranked_by_user_create_list
  editor_for :manage_list, :name => "Manage list", :feature => :ranked_by_user_manage_list, :inputs => { :list_id => [[ :url, 'List Identifier', :path ]] }
  editor_for :my_lists, :name => "My Lists", :feature => :ranked_by_user_my_lists

  user_actions :lookup, :create_list_add_item, :add_item, :edit, :remove_item, :reorder

  class CreateListOptions < HashModel
    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end

  class ManageListOptions < HashModel
    attributes :manage_list_page_id => nil

    page_options :manage_list_page_id
    
    options_form(
                 # fld(:success_page_id, :page_selector) # <attribute>, <form element>, <options>
                 )
  end

  class MyListsOptions < HashModel
    attributes :manage_list_page_id => nil

    page_options :manage_list_page_id

    validates_presence_of :manage_list_page_id

    options_form(
                 fld(:manage_list_page_id, :page_selector)
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

    item = list.add_item(@user.lookup_by_identifier(params[:identifier]))

    @generating_thumbnail = true;

    render :partial => "/ranked_by/user/item",:locals => { :item => item, :index => 0, :editable => true }
  end

  def remove_item
    @user = ranked_by_user

    list = @user.get_list_by_id(params[:list_id])

    list.items.delete(list.items.find_by_id(params[:item_id]))

    render :nothing => true
  end

  def reorder 
    @user = ranked_by_user

    list = @user.get_list_by_id(params[:list_id])

    params[:item].each_with_index do |itm_id,idx|
      list.items.detect { |itm| itm.id == itm_id.to_i }.update_attributes(:ranking => -1 * idx)
    end

    render :nothing => true
  end

  def edit
    @user = ranked_by_user

    list = @user.get_list_by_id(params[:list_id])

    fields = { 'list-title' => :name,
               'list-author' => :author }

    item_fields = { 'title' => :name,
                    'description' => :description }

    if fields[params[:id]]
      list.update_attributes(fields[params[:id]] => params[:value])
    elsif params[:id] =~ /item-([a-z]+)-([0-9]+)/
      item = list.items.find_by_id($2)
      item.update_attributes(item_fields[$1] => params[:value]) if item_fields[$1] && item
    end

    render :text => params[:value]
  end

end
