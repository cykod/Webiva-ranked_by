class RankedBy::ManageController < ModuleController
  permit 'ranked_by_manage'
  
  component_info 'RankedBy'
  
  cms_admin_paths 'content'
  
  include ActiveTable::Controller
  active_table :list_table,
                RankedByList,
                [ :name,
                  :description,
                  :author,
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
end
