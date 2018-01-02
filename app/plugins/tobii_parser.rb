require 'CSV'

class TobiiParser
  attr_accessor :metadata

  def initialize(metadata)
    ap metadata
    @metadata = JSON.parse(metadata.gsub("'", '"'))
    ap @metadata
  end

  def injest
  end

  def query(time_series, username, groupname, sessionname)
    csv_opts = { :headers => true, :col_sep => "\t", :return_headers => true}

    input = CSV.open(time_series.file.file.file, csv_opts)
    Enumerator.new do |yielder|
      until input.eof
        row = input.readline()
        yielder << CSV.generate_line(row, csv_opts)
      end
    end
  end
end