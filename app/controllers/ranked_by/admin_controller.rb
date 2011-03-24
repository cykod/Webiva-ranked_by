
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

  content_model :ranked_by
  
  module_for :embed, 'Embed Ranked By List', :description => 'Generates embed code for Ranked By Lists'
  
  layout false
  
  public 

  def self.get_ranked_by_info
    [{ :name => 'Ranked By Lists', :url => { :controller => '/ranked_by/manage', :action => 'lists' }, :permission => :ranked_by_manage }
     ]
  end

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
    attributes :amazon_access_key => nil, :amazon_secret => nil, :amazon_associate_tag => nil, :webthumb_bluga_api_key => nil, :notify_url => nil

    validates_presence_of :amazon_access_key, :amazon_secret

    options_form(
                 fld(:amazon_access_key, :text_field, :required => true),
                 fld(:amazon_secret, :text_field, :required => true),
                 fld(:amazon_associate_tag, :text_field),
                 fld(:webthumb_bluga_api_key, :text_field),
                 fld(:notify_url, :text_field)
                 )
    
    def create_amazon_product_web_service
      service = AmazonProductWebService.new self.amazon_access_key, self.amazon_secret
      service.associate_tag = self.amazon_associate_tag unless self.amazon_associate_tag.blank?
      service
    end
    
    def create_webthumb_bluga_web_service
      service = WebthumbBlugaWebService.new self.webthumb_bluga_api_key
      service.notify_url = self.notify_url.blank? ? self.default_notify_url : self.notify_url
      service
    end
    
    def default_notify_url
      Configuration.domain_link '/website/ranked_by/thumbnail/notify'
    end
  end

  def embed
    @node = SiteNode.find_by_id_and_module_name(params[:path][0],'/ranked_by/embed') unless @node

    @page_modifier = @node.page_modifier

    @options = EmbedOptions.new(params[:options] || @page_modifier.modifier_data || {})
    
    if request.post? && params[:options] && @options.valid?
      @page_modifier.update_attribute(:modifier_data, @options.to_h)
      expire_site
      flash.now[:notice] = 'Updated Options'
     end
  end

  class EmbedOptions < HashModel
  end
end
