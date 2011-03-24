class WebthumbBlugaWebService < RESTHome
  base_uri 'http://webthumb.bluga.net'
  headers 'Content-Type' => 'application/xml'

  route :create_thumbnail, '/api.php' do |res|
    res['webthumb']
  end

  route :create_status, '/api.php' do |res|
    res['webthumb']
  end

  attr_accessor :notify_url
  
  def initialize(api_key)
    @api_key = api_key
  end

  def build_options!(options)
    @error_response = nil
    body = options[:body]
    if body
      body[:version] = 3
      body[:apikey] = @api_key
      body[:request][:notify] = self.notify_url if self.notify_url && body[:request]

      options[:body] = body.to_xml(:root => 'webthumb', :skip_types => true, :skip_instruct => true)
    end
  end

  def error_response
    @error_response ||= HTTParty::Parser.call self.response.body, HTTParty::Parser.format_from_mimetype(self.response.headers['content-type'])
  end
  
  def job_status(jobs, opts={})
    jobs = [jobs] unless jobs.is_a?(Array)
    opts.merge!(:jobs => Proc.new { |o| jobs.map{|job| o[:builder].job(job) }})
    self.create_status :status => opts
  end
  
  def thumbnail(url, opts={})
    opts.merge!(:url => url)
    self.create_thumbnail :request => opts
  end
  
  def self.generate_url(job, size='thumb_large', type='jpg')
    "#{self.base_uri}/data/#{job[-2..-1]}/#{job[-4..-3]}/#{job[-6..-5]}/#{job}-#{size}.#{type}"
  end
end
