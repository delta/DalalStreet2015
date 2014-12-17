class DataCache
  def self.data
    @data ||= Redis.new(host: 'localhost', port: 6379)
  end

  def self.set(key, value)
    data.set(key, value)
  end

  def self.get(key)
    data.get(key)
  end

  def self.get_i(key)
    data.get(key).to_i
  end
end