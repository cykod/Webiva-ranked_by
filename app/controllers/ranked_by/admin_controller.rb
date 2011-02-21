
class RankedBy::AdminController < ModuleController

  component_info 'RankedBy', :description => 'Ranked By support', 
                              :access => :public
                              
  # Register a handler feature
  register_permission_category :ranked_by, "RankedBy" ,"Permissions related to Ranked By"
  
  register_permissions :ranked_by, [ [ :manage, 'Manage Ranked By', 'Manage Ranked By' ],
                                  [ :config, 'Configure Ranked By', 'Configure Ranked By' ]
                                  ]
  cms_admin_paths "options",
     "Ranked By Options" => { :action => 'index' },
     "Options" => { :controller => '/options' },
     "Modules" => { :controller => '/modules' }

  permit 'ranked_by_config'

  public 
 
  def options
    cms_page_path ['Options','Modules'],"Ranked By Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Ranked By module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
   # Options attributes 
   # attributes :attribute_name => value
  
  end

end
