module Denilize
  # https://stackoverflow.com/questions/23903055/how-to-replace-all-nil-value-with-in-a-ruby-hash-recursively
  def self.denilize(h)
    h.each_with_object({}) { |(k,v),g|
      g[k] = (Hash === v) ?  denilize(v) : v ? v : '' }
  end
end
