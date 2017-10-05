class Hash
  #https://gist.github.com/henrik/146844
  def deep_diff(b, exceptions = [])
    a = self
    (a.keys | b.keys).inject({}) do |diff, k|
      if a[k] != b[k] && !exceptions.any? { |key| k.include?(key) }
        if a[k].respond_to?(:deep_diff) && b[k].respond_to?(:deep_diff)
          diff[k] = a[k].deep_diff(b[k])
        else
          if a[k].present? && b[k].present?
            if a[k].instance_of?(Array) && a[k].first.instance_of?(Hash)
              a[k].each_with_index do |hash, index|
                if (b[k][index]).present?
                  diff[k] = hash.deep_diff(b[k][index])
                else
                  diff[k] = [a[k], b[k]]
                end
              end
            else
              diff[k] = [a[k], b[k]]
            end
          else
            diff[k] = [a[k], b[k]]
          end
        end
      end
      diff.delete_blank
    end
  end
  
  def delete_blank
    delete_if{|k, v| v.empty? or v.instance_of?(Hash) && v.delete_blank.empty?}
  end
end