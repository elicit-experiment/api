# frozen_string_literal: true

require 'test_helper'

class Hash
  def diff(other)
    (keys + other.keys).uniq.each_with_object({}) do |key, memo|
      next if self[key] == other[key]

      memo[key] = if self[key].is_a?(Hash) && other[key].is_a?(Hash)
                    self[key].diff(other[key])
                  else
                    [self[key], other[key]]
                  end
    end
  end
end

class ExperimentXmlTest < ActiveSupport::TestCase
  experiment_xml_files = ['freetexttest.xml', 'checkboxgrouptest.xml', 'likertscaletest.xml', 'radiobottongrouptest.xml', 'onedscaletest.xml']

  experiment_xml_files.each do |experiment_xml|
    test "#get_experiment #{experiment_xml}" do
      exp, exp_n = ExperimentXmls.instance.load_experiment(file_fixture("experiment_xmls/#{experiment_xml}"))
      id = exp['Experiment']['Id']
      expected_response = JSON.parse(file_fixture("production_examples/experiment_#{id}.json").read)
      x = ExperimentXmls.get_experiment(exp)
      expected = expected_response['Body']['Results'][0]
      ap x.diff(expected)
      assert_equal x, expected
    end
  end

  experiment_xml_files.each do |experiment_xml|
    test "#get_questions #{experiment_xml}" do
      exp, exp_n = ExperimentXmls.instance.load_experiment(file_fixture("experiment_xmls/#{experiment_xml}"))
      id = exp['Experiment']['Id']
      no_trials = exp['Experiment']['NoOfTrials'].to_i
      puts no_trials
      (0..no_trials).each do |trial|
        begin
          json_output = file_fixture("production_examples/questions_#{id}_#{trial}.json")
        rescue StandardError
          next
        end
        expected_response = JSON.parse(json_output.read)
        x = ExperimentXmls.get_questions(exp_n, trial)
        expected = expected_response['Body']['Results']
        expected.each do |exp|
          # clean up any monitor information from the 'real' server files
          exp['Output'] = if exp['Type'].eql? 'Monitor'
                            {
                              'Context' => {
                                'Data' => '',
                                'Type' => ''
                              },
                              'Events' => ''
                            }
                          else
                            {}
                          end
        end
        assert_equal x.count, expected.count
        x.each_with_index do |act, i|
          # puts "ACTUAL #{i}"
          # ap act, { sort_keys: true, indent: 2 }
          # puts "EXPECTED #{i}"
          # ap expected[i], { sort_keys: true, indent: 2 }
          # puts "DIFF #{i}"
          # ap act.diff(expected[i]), { sort_keys: true, indent: 2 }
          assert_equal act, expected[i]
        end
      end
    end
  end
end
