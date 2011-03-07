

class RankedByItem < DomainModel
  belongs_to :ranked_by_list

  has_domain_file :image_file_id

  def small_image_name
    self.small_image_url.split('/')[-1] if self.small_image_url
  end

  def large_image_name
    self.large_image_url.split('/')[-1] if self.large_image_url
  end
  
  def refresh(user)
    return unless self.item_type == 'amazon'
    data = nil
    begin
      data = user.lookup_amazon self.identifier.split('=')[-1]
    rescue RESTHome::InvalidResponse
    end
    return unless data
    self.name = data[:name] unless self.custom_name
    self.description = data[:description] unless self.custom_description
    self.small_image_url = data[:images][:thumb]
    self.large_image_url = data[:images][:full]
    self.save
  end
end
