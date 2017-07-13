require 'nokogiri'

#https://stackoverflow.com/questions/1230741/convert-a-nokogiri-document-to-a-ruby-hash
class Nokogiri::XML::Node
  TYPENAMES = {1=>'element',2=>'attribute',3=>'text',4=>'cdata',8=>'comment'}
  def to_hash
    {kind:TYPENAMES[node_type],name:name}.tap do |h|
      h.merge! nshref:namespace.href, nsprefix:namespace.prefix if namespace
      h.merge! text:text
      h.merge! attr:attribute_nodes.map(&:to_hash) if element?
      h.merge! kids:children.map(&:to_hash) if element?
    end
  end
end

class ExperimentXmls
  include Singleton

  attr_accessor :experiments
  attr_accessor :experiments_n
  attr_accessor :experiment_by_id

  def refresh
    root = File.join Rails.root, "experiment_xmls"

    @experiments = []
    @experiments_n = []
    @experiment_by_id = {}

    Dir.glob(File.join(root, "*.xml")).each do |experiment_file|
      load_experiment(experiment_file)
    end

    ap @experiment_by_id
  end

  def load_experiment(experiment_file)
    exp = Hash.from_xml(File.read(experiment_file))
    exp_n = Nokogiri.XML(File.read(experiment_file))
    @experiments << exp
    @experiment_by_id[exp["Experiment"]["Id"]] = exp
    @experiments_n << exp_n
    [exp, exp_n]
  end

  def self.get_experiment(experiment)
    experiment["Experiment"].map.reject { |k,v| k.eql? "Trials" }.to_h
  end

  def self.get_questions(experiment, trial_no = 0)
    trial = experiment.css("Experiment Trials").children[trial_no].children

    results = trial.each_with_index.map do |element, index|
      #input = element.css("Inputs")[0].children.map(&:to_hash)
      #output = element.css("Outputs")[0].children.reject{ |n| n.text.blank? }.map(&:to_hash)
      input = element.css("Inputs")[0].children.map{|x| Hash.from_xml(x.to_s)}
      output = element.css("Outputs")[0].children.map{|x| Hash.from_xml(x.to_s)}
      {
        "Fullname": "Question, 1.0.0",
        "Id": "a9f56a58-aaaa-eeee-1355-012345678904:#{index}",
        "Input": input,
        "Output": output,
        "Type": element.name,
        "UserAnswer": nil
      }
    end

    ap results
    results
  end
end
