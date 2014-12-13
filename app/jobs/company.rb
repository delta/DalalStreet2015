module Company
  @queue = :company
  def self.perform()
    # Do anything here, like access models, etc
    a = 1
    a = a +1
    logger.info a
    
  end
end
