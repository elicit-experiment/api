# frozen_string_literal: true

require 'nokogiri'

# https://stackoverflow.com/questions/1230741/convert-a-nokogiri-document-to-a-ruby-hash
class Nokogiri::XML::Node
  TYPENAMES = { 1 => 'element', 2 => 'attribute', 3 => 'text', 4 => 'cdata', 8 => 'comment' }.freeze
  def to_hash
    { kind: TYPENAMES[node_type], name: name }.tap do |h|
      if namespace
        h[:nshref] = namespace.href
        h[:nsprefix] = namespace.prefix
      end
      h[:text] = text
      h[:attr] = attribute_nodes.map(&:to_hash) if element?
      h.merge! kids: children.map(&:to_hash) if element?
    end
  end
end

class ExperimentXmls
  include Singleton

  include Denilize

  attr_accessor :experiments
  attr_accessor :experiments_n
  attr_accessor :experiment_by_id
  attr_accessor :experiment_n_by_id

  def initialize
    @experiments = []
    @experiments_n = []
    @experiment_by_id = {}
    @experiment_n_by_id = {}
  end

  def refresh
    root = File.join Rails.root, 'experiment_xmls'

    Dir.glob(File.join(root, '*.xml')).each do |experiment_file|
      exp, exp_n = load_experiment(experiment_file)
      id = exp['Experiment']['Id']

      #      e = Experiment.find_or_create_by(ExperimentId: id)
      #      e.attributes = {
      #        :ExperimentId => id,
      #        :Name => exp["Experiment"]["Name"],
      #        :Version => exp["Experiment"]["Version"].to_i,
      #        :ExperimentDescription => exp["Experiment"]["ExperimentDescription"],
      #        :CreatedBy => exp["Experiment"]["CreatedBy"],
      #        :LockQuestion => exp["Experiment"]["LockQuestion"],
      #        :EnablePrevious => exp["Experiment"]["EnablePrevious"],
      #        :NoOfTrials => exp["Experiment"]["NoOfTrials"],
      #        :TrialsCompleted => exp["Experiment"]["TrialsCompleted"],
      #        :FooterLabel => exp["Experiment"]["FooterLabel"],
      #        :RedirectOnCloseUrl => exp["Experiment"]["RedirectOnCloseUrl"],
      #        :FileName => experiment_file,
      #      }
      #      e.save!

      #      p = Protocol.new()
      #      p.attributes = {
      #        :Name => exp["Experiment"]["Name"],
      #        :Version => 1,
      #        :Type => "ExperimentXml",
      #        :DefinitionData => experiment_file
      #      }
      #      p.save!
    end
  end

  def load_experiment_by_id(id)
    root = File.join Rails.root, 'experiment_xmls'
    file_name = File.join(root, "#{id}.xml")

    load_experiment(file_name)
  end

  def load_experiment(experiment_file)
    exp = Hash.from_xml(File.read(experiment_file))
    exp_n = Nokogiri.XML(File.read(experiment_file))
    id = exp['Experiment']['Id']
    no_of_trials = exp['Experiment']['NoOfTrials'].to_i
    trial_elements = exp_n.css('//Experiment/Trials/Trial').count
    Rails.logger.error("#{no_of_trials} vs #{trial_elements} for #{experiment_file} #{exp_n.css('Experiment>Trials').children}") unless trial_elements == no_of_trials
    @experiments << exp
    @experiment_by_id[id] = exp
    @experiments_n << exp_n
    @experiment_n_by_id[id] = exp_n

    [exp, exp_n]
  end

  def self.get_experiment(experiment)
    e = experiment['Experiment'].map.reject { |k, _v| k.eql? 'Trials' }.to_h
    e['Css'] = '' unless e.key? 'Css'
    e['CurrentSlideIndex'] = 0
    e['LockQuestion'] = e['LockQuestion'] == '1'
    e['EnablePrevious'] = e['EnablePrevious'] == '1'
    e['Fullname'] = 'Questionnaire, 1.0'
    e['RedirectOnCloseUrl'] = '' if e['RedirectOnCloseUrl'].nil?
    e.delete 'NoOfTrials'
    e.delete 'TrialsCompleted'
    e.delete 'Target'
    e.delete 'CreatedBy'
    e.delete 'ExperimentDescription'
    e
  end

  def self.get_questions(experiment, trial_no = 0)
    id = experiment.css('Experiment>Id').text
    trial_els = experiment.css('//Experiment/Trials/Trial')
    # ap trial_els.children
    num_trials = trial_els.count
    Rails.logger.info "Trials #{id} #{experiment.css('Experiment>Name').text} #{num_trials} -- #{trial_no}"
    base_question_no = 0
    if trial_no > 0
      base_question_no = (0..(trial_no - 1)).map { |t| trial_els[t].children.count }.reduce(&:+)
    end
    trial = trial_els[trial_no].children
    results = trial.reject { |e| e.name.eql?('text') && e.text.blank? }.each_with_index.map do |element, index|
      # ap element.css("Inputs").children.map{|x| x.to_s}.reject{ |s| s =~ /^\s*$/ }.map{ |s| Hash.from_xml(URI.unescape(s)) }
      input = element.css('Inputs').map { |i| i.children.map { |x| URI.unescape(x.to_s) }.reject { |s| s =~ /^\s*$/ }.map { |s| Hash.from_xml(s) } }.first
      output = element.css('Outputs').map do |o|
        (o.children || []).map { |x| URI.unescape(x.to_s) }.reject { |s| s =~ /^\s*$/ }.map do |s|
          h = Hash.from_xml(s)
          h.delete('Validation')
          h = h.compact
        end .reject(&:empty?)
      end.reject(&:empty?).flatten
      output = output.reduce({}, :merge)['Value'] || {}
      output = {} unless element.name.eql? 'Monitor'
      output = Denilize.denilize(output)

      if (output == {}) && input.nil?
        Rails.logger.error(" invalid text: #{element.to_xml.ai}")
      end
      question_no = base_question_no + index
      {
        'Fullname' => 'Question, 1.0.0',
        'Id' => "#{id}:#{question_no}",
        'Input' => input,
        'Output' => output,
        'Type' => element.name,
        'UserAnswer' => nil
      }
    end

    results
  end
end
