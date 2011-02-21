
yaml_file = File.join(File.dirname(__FILE__), '..', "config", "oembed_links.yml")
if File.exists?(yaml_file)
  OEmbed::register_yaml_file(yaml_file)
end

class RankedByOembed
  attr_accessor :link, :post_type, :data

  def process_request(opts={})
    self.data = {}

    maxwidth = opts[:maxwidth] || '340'
    maxheight = opts[:maxheight] ? opts[:maxheight].to_s : nil
    OEmbed.transform(self.link, false, {'maxwidth' => maxwidth.to_s, 'maxheight' => maxheight}.delete_if{|k,v| v.blank?}) do |r, url|
      r.video? { |d| self.post_type = 'media'; self.data = d.to_hash.symbolize_keys; '' }
      r.photo? { |d| self.post_type = 'image'; self.data = d.to_hash.symbolize_keys; '' }
      r.rich? { |d| self.post_type = 'media'; self.data = d.to_hash.symbolize_keys; '' }
      r.link? { |d| self.post_type = 'link'; self.data = d.to_hash.symbolize_keys; '' }
    end

    unless self.data.empty?
      if self.data[:type] == 'video' || self.data[:type] == 'rich'
        if self.data[:html].blank?
          if ! self.data[:thumbnail_url].blank?
            self.data[:type] = 'photo'
            self.data[:image_url] = self.data[:thumbnail_url]
          else
            self.data = {}
          end
        end
      elsif self.data[:type] == 'photo'
        self.data[:image_url] = self.data[:url]
      end

      if self.data[:image_url]
        image_size = DomainFile.remote_image_size(self.data[:image_url])
        if image_size
          self.data[:width] = image_size[0]
          self.data[:height] = image_size[1]
        end
      end

      if self.data[:thumbnail_url]
        image_size = DomainFile.remote_image_size(self.data[:thumbnail_url])
        if image_size
          self.data[:thumbnail_width] = image_size[0]
          self.data[:thumbnail_height] = image_size[1]
        end
      end
    end

    self.data.empty? ? false : true
  end

  class RankedByHTTP
    def name
      "RankedByHTTP"
    end

    def fetch(url)
      uri = nil
      begin
        uri = URI.parse(url)
      rescue URI::InvalidURIError => e
        return nil
      end

      link = uri.query.split('&').find { |arg| arg =~ /^url=/ }
      return nil unless link

      link = CGI::unescape(link.sub('url=', ''))

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request_get("#{uri.path}?#{uri.query}", {'User-Agent' => 'Webiva'}) do |response|
          begin
            response.value
            return response.body
          rescue
            Rails.logger.error "failed to fetch: #{url}"
          end
        end
      end
      nil
    end
  end

  class JSON < OEmbed::Formatters::JSON
    def format(txt)
      return {} if txt.blank?
      super(txt)
    end
  end

  class XML < OEmbed::Formatters::LibXML
    def format(txt)
      return {} if txt.blank?
      super(txt)
    end
  end  

  def image_url
    self.data[:image_url]
  end

  def width
    self.data[:width]
  end

  def height
    self.data[:height]
  end

  def name
    self.data[:title]
  end

  def description
    self.data[:description]
  end

  def author_name
    self.data[:author_name]
  end

  def author_url
    self.data[:author_url]
  end

  def provider_name
    self.data[:provider_name]
  end

  def provider_url
    self.data[:provider_url]
  end

  def embeded_html
    self.data[:html]
  end

  def thumbnail_url
    self.data[:thumbnail_url]
  end

  def thumbnail_width
    self.data[:thumbnail_width]
  end

  def thumbnail_height
    self.data[:thumbnail_height]
  end
  
  def parse_item
    { :name => self.name,
      :link => self.link,
      :description => self.description,
      :identifier => "link=#{self.link}",
      :images => {:thumb => self.thumbnail_url, :preview => self.image_url}
    }
  end
end

OEmbed.register_fetcher(RankedByOembed::RankedByHTTP)
OEmbed.register_formatter(RankedByOembed::JSON)
OEmbed.register_formatter(RankedByOembed::XML)
