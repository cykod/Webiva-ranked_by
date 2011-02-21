
class RatedBy::AdminController < ModuleController

  component_info 'RatedBy', :description => 'Rated By support', 
                              :access => :public
                              
  # Register a handler feature
  register_permission_category :rated_by, "RatedBy" ,"Permissions related to Rated By"
  
  register_permissions :rated_by, [ [ :manage, 'Manage Rated By', 'Manage Rated By' ],
                                  [ :config, 'Configure Rated By', 'Configure Rated By' ]
                                  ]
  cms_admin_paths "options",
     "Rated By Options" => { :action => 'index' },
     "Options" => { :controller => '/options' },
     "Modules" => { :controller => '/modules' }

  permit 'rated_by_config'

  public 
 
  def options
    cms_page_path ['Options','Modules'],"Rated By Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Rated By module options".t 
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
