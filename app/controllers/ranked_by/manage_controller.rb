class RankedBy::ManageController < ModuleController
  permit 'ranked_by_manage'
  
  component_info 'RankedBy'
  
  cms_admin_paths 'content',
                  'Ranked By Lists' => {:action => 'lists'}
  
  include ActiveTable::Controller
  active_table :list_table,
                RankedByList,
                [ :check,
                  :name,
                  :description,
                  :author,
                  :permalink,
                  hdr(:static, 'User'),
                  :views,
                  hdr(:static, '# Items'),
                  :updated_at,
                  :created_at
                ]

  def display_list_table(display=true)
    active_table_action 'list' do |act, ids|
      case act
      when 'delete'
        RankedByList.destroy ids
      end
    end

    @active_table_output = list_table_generate params, :order => 'created_at DESC'
    
    render :partial => 'list_table' if display
  end

  def lists
    display_list_table(false)
    cms_page_path ['Content'], 'Ranked By Lists'
  end
  
  def list
    @list = RankedByList.find params[:path][0]
    if request.post? && params[:list] && @list.update_attributes(params[:list])
      flash[:notice] = 'List updated'
      redirect_to :action => 'lists'
      return
    end
    
    cms_page_path ['Content', 'Ranked By Lists'], 'Edit List'
  end
  
  active_table :list_item,
                RankedByItem,
                [ :check,
                  hdr(:static, 'Image'),
                  :name,
                  :ranking,
                  :description,
                  :item_type,
                  :identifier,
                  :source_domain,
                  :small_image_url,
                  :large_image_url,
                  :updated_at,
                  :created_at
                ]


  def display_item_table(display=true)
    @list ||= RankedByList.find params[:path][0]

    active_table_action 'item' do |act, ids|
      case act
      when 'delete'
        RankedByItem.destroy ids
      end
    end

    @active_table_output = list_item_generate params, :conditions => ['ranked_by_list_id = ?', @list.id], :order => 'created_at DESC'

    render :partial => 'item_table' if display
  end
  
  def items
    display_item_table(false)
    cms_page_path ['Content', 'Ranked By Lists'], "#{@list.name} - Items"
  end
  
  def item
    @list = RankedByList.find params[:path][0]
    @item = @list.items.find params[:path][1]
    
    if request.post? && params[:item] && @item.update_attributes(params[:item])
      flash[:notice] = 'Item updated'
      redirect_to :action => 'items', :path => @list.id
      return
    end
    
    cms_page_path ['Content', 'Ranked By Lists', ["#{@list.name} - Items", {:action => 'items', :path => @list.id}]], "Edit #{@item.name}"
  end
end
