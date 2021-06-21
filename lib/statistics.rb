# frozen_string_literal: true

module Statistics
  def mean
    self.sum / self.size.to_f
  end
  
  def median
    return nil if self.empty?
    
    sorted = self.sort
    size   = sorted.size
    (sorted[(size - 1) / 2] + sorted[size / 2]) / 2.0
  end
  
  def variance
    arithmetic_mean = self.mean
    (self.map { |value| (arithmetic_mean - value)**2 }).mean
  end
  
  def standard_deviation
    Math.sqrt(self.variance)
  end
end

class Array
  include Statistics
end
