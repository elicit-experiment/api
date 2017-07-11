class ExperimentXmls
  include Singleton

  attr_accessor :experiments
  attr_accessor :experiment_by_id

  def refresh
    root = File.join Rails.root, "experiment_xmls"

    @experiments = Dir.glob(File.join(root, "*.xml")).map do |experiment_file|
      ap experiment_file
      Hash.from_xml File.read(experiment_file)
    end

    @experiment_by_id = @experiments.map{ |e| [e["Experiment"]["Id"], e] }.to_h

    ap @experiment_by_id
  end
end
