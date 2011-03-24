
class RankedByList < DomainModel

  before_create :create_permalink
  validates_uniqueness_of :permalink

  belongs_to :ranked_by_user
  has_many :items, :class_name => 'RankedByItem', :foreign_key => 'ranked_by_list_id', :order => 'ranking DESC'


  def add_item(data)
    self.items.create RankedByItem.item_data(data)
  end

  def as_json(options = {})
    {:list => self.attributes.slice('permalink', 'name', 'description', 'author').merge(:items => self.items.collect{ |i| i.as_json(options.merge(:no_wrap => true))})}
  end

  def num_items
    self.items.count
  end

  def refresh(opts={})
    self.items.each { |i| i.refresh self.ranked_by_user }
  end

  def must_refresh
    if (self.updated_at + 1.day) < Time.now
      self.updated_at = Time.now
      self.save
      self.run_worker(:refresh)
    end
  end
  
  def increment_views
    self.connection.execute("UPDATE ranked_by_lists SET views = views + 1 WHERE id = #{self.id}")
    self.views += 1
  end
  
  def generate_permalink
    cnt = 1
    base_path = SiteNode.generate_node_path "#{self.author}-#{self.name}"
    test_path = base_path
    while RankedByList.first(:conditions => ['permalink = ? && id != ?', test_path, self.id])
      cnt += 1
      test_path = "#{base_path}-#{cnt}"
    end
    self.permalink = test_path
  end

  protected

  def create_permalink
    self.permalink = DomainModel.generate_hash[0..20]
  end
end
