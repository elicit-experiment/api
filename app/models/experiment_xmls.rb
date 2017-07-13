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
    e = experiment["Experiment"].map.reject { |k,v| k.eql? "Trials" }.to_h
    e["Css"] = nil unless e.has_key? "Css"
    e["CurrentSlideIndex"] = 0
    e["LockQuestion"] = e["LockQuestion"] == "1"
    e["EnablePrevious"] = e["EnablePrevious"] == "1"
    e["Fullname"] = "Questionnaire, 1.0"
    e["RedirectOnCloseUrl"] = "" if e["RedirectOnCloseUrl"].nil?
    e.delete "NoOfTrials"
    e.delete "TrialsCompleted"
    e.delete "Target"
    e.delete "CreatedBy"
    e.delete "ExperimentDescription"
    e
  end

  # https://stackoverflow.com/questions/23903055/how-to-replace-all-nil-value-with-in-a-ruby-hash-recursively
  def self.denilize(h)
    h.each_with_object({}) { |(k,v),g|
      g[k] = (Hash === v) ?  denilize(v) : v ? v : '' }
  end

  def self.get_questions(experiment, trial_no = 0)
    id = experiment.css("Experiment>Id").text
    base_question_no = 0
    if trial_no > 0
      base_question_no = (0..(trial_no-1)).map { |t| experiment.css("Experiment>Trials").children[t].children.count }.reduce(&:+)
    end
    trial = experiment.css("Experiment>Trials").children[trial_no].children

    results = trial.each_with_index.map do |element, index|
      #input = element.css("Inputs")[0].children.map(&:to_hash)
      #output = element.css("Outputs")[0].children.reject{ |n| n.text.blank? }.map(&:to_hash)
      input = element.css("Inputs").map{ |i| i.children.map{ |x| Hash.from_xml(URI.unescape(x.to_s)) } }.first
      output = element.css("Outputs").map{ |o|
        o.children.map{ |x|
          h = Hash.from_xml(x.to_s)
          h.delete('Validation')
          h = h.compact }.reject{ |c| c.empty? }
      }.reject{ |c| c.empty? }.flatten
      output = output.reduce({}, :merge)["Value"] || {}
      output = {} unless element.name.eql? "Monitor"
      output = ExperimentXmls.denilize(output)

      question_no = base_question_no+ index
      {
        "Fullname" => "Question, 1.0.0",
        "Id" => "#{id}:#{question_no}",
        "Input" => input,
        "Output" => output,
        "Type" => element.name,
        "UserAnswer" => nil
      }
    end

    results
  end
end
