

class RankedByItem < DomainModel
  belongs_to :ranked_by_list

  has_domain_file :image_file_id

  def small_image_name
    self.small_image_url.split('/')[-1] if self.small_image_url
  end

  def large_image_name
    self.large_image_url.split('/')[-1] if self.large_image_url
  end
end
