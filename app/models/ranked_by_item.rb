
class RankedByItem < DomainModel
  belongs_to :ranked_by_list

  has_domain_file :image_file_id

  after_create :fetch_thumbnail

  def small_image_name
    self.small_image_url.split('/')[-1] if self.small_image_url
  end

  def large_image_name
    self.large_image_url.split('/')[-1] if self.large_image_url
  end
  
  def self.item_data(data)
    data[:images] ||= {}

    { :name => data[:name],
      :item_type => data[:item_type],
      :identifier => data[:identifier],
      :source_domain => data[:source_domain],
      :url => data[:link], 
      :small_image_url => data[:images][:thumb],
      :large_image_url => data[:images][:preview],
      :description => Util::TextFormatter.text_plain_generator(data[:description]).to_s.gsub(/  +/, ' ').strip[0..200]
    }
  end

  def refresh(user)
    return unless self.item_type == 'amazon'
    data = nil
    begin
      data = RankedByItem.item_data(user.lookup_amazon(self.identifier.split('=')[-1]))
    rescue RESTHome::InvalidResponse
    end
    return unless data
    self.name = data[:name] unless self.custom_name
    self.description = data[:description] unless self.custom_description
    self.url = data[:url]
    self.small_image_url = data[:small_image_url]
    self.large_image_url = data[:large_image_url]
    self.save
  end
  
  def fetch_thumbnail
    return unless self.identifier.split('=')[0] == 'link'
    s = self.class.thumbnail_service
    res = s.thumbnail self.url
    if res['jobs']['job']
      job = res['jobs']['job']
      DataCache.put_cached_container 'RankedByItem::Thumbnails', job, self.id
      job
    end
  end
  
  def self.thumbnail_service
    RankedBy::AdminController.module_options.create_webthumb_bluga_web_service
  end
  
  def self.update_cached_item(job)
    item_id = DataCache.get_cached_container 'RankedByItem::Thumbnails', job
    return unless item_id
    item = RankedByItem.find_by_id item_id
    return unless item
    image_file = self.ranked_by_folder.add WebthumbBlugaWebService.generate_url(job)
    if image_file && image_file.id
      item.image_file_id = image_file.id
      item.save
    end
  end
  
  def self.ranked_by_folder
    DomainFile.push_folder 'Thumbnails', :parent_id => DomainFile.push_folder('Ranked By').id
  end
  
  def small_image_url
    self.image_file ? self.image_file.full_url(:thumb) : self[:small_image_url]
  end

  def large_image_url
    self.image_file ? self.image_file.full_url : self[:large_image_url]
  end
  
  def as_json(options={})
    data = self.attributes.slice('id', 'name', 'item_type', 'identifier', 'url', 'description','ranking')
    data['large_image_url'] = self.large_image_url
    data['small_image_url'] = self.small_image_url
    options[:no_wrap] ? data : {:item => data}
  end
end
