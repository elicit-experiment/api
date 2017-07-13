require 'test_helper'

class ExperimentXmlTest < ActiveSupport::TestCase
  test "#get_experiment" do
    exp, exp_n = ExperimentXmls.instance.load_experiment(file_fixture('experiment_xmls/freetexttest.xml'))
    x = ExperimentXmls.get_experiment(exp)
    assert_equal x, {"Id"=>"a9f56a58-aaaa-eeee-1355-012345678901", "Name"=>"freetext test", "Version"=>"1", "Target"=>{"Id"=>"null", "Name"=>"null"}, "ExperimentDescription"=>"Description of the freetext test.", "CreatedBy"=>"Jens Madsen", "LockQuestion"=>"0", "EnablePrevious"=>"1", "NoOfTrials"=>"2", "TrialsCompleted"=>"0", "FooterLabel"=>"Footer for the freetext test", "RedirectOnCloseUrl"=>nil}
  end
  test "#get_questions" do
    exp, exp_n = ExperimentXmls.instance.load_experiment(file_fixture('experiment_xmls/freetexttest.xml'))
    x = ExperimentXmls.get_questions(exp_n, 0)
    pp x
    expected = [{:Fullname=>"Question, 1.0.0",
                      :Id=>"a9f56a58-aaaa-eeee-1355-012345678904:0",
                      :Input=>[{"HeaderLabel"=>"Freetext test"}],
                      :Output=>[{"Validation"=>nil}, {"Value"=>nil}],
                      :Type=>"Header",
                      :UserAnswer=>nil},
                     {:Fullname=>"Question, 1.0.0",
                      :Id=>"a9f56a58-aaaa-eeee-1355-012345678904:1",
                      :Input=>
                      [{"Events"=>nil},
                       {"Instrument"=>
                        {"Label"=>"Only digits here (LabelPosition=top)",
                         "LabelPosition"=>"top",
                         "Validation"=>"^[0-9]%2B$",
                         "BoxWidth"=>nil,
                         "BoxHeight"=>nil,
                         "Resizable"=>nil}}],
                      :Output=>
                      [{"Validation"=>
                        {"SimpleValue"=>{"Id"=>"Text", "Validation"=>"^[0-9]%2B$"},
                         "MultiValue"=>
                         {"Id"=>"Events",
                          "Max"=>"Inf",
                          "Min"=>"0",
                          "ComplexValue"=>
                          {"Id"=>"Event",
                           "SimpleValue"=>
                           [{"Id"=>"DateTime",
                             "Validation"=>
                             "(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}.\\d{3})Z"},
                            {"Id"=>"Type", "Validation"=>".*"},
                            {"Id"=>"Id", "Validation"=>".*"},
                            {"Id"=>"Data", "Validation"=>".*"},
                            {"Id"=>"Method", "Validation"=>".*"}]}}}}],
                      :Type=>"Freetext",
                      :UserAnswer=>nil},
                     {:Fullname=>"Question, 1.0.0",
                      :Id=>"a9f56a58-aaaa-eeee-1355-012345678904:2",
                      :Input=>
                      [{"Events"=>nil},
                       {"Instrument"=>
                        {"Label"=>"Any char here (LabelPosition=right)",
                         "LabelPosition"=>"right",
                         "Validation"=>".%2B",
                         "BoxWidth"=>nil,
                         "BoxHeight"=>nil,
                         "Resizable"=>nil}}],
                      :Output=>
                      [{"Validation"=>
                        {"SimpleValue"=>{"Id"=>"Text", "Validation"=>".%2B"},
                         "MultiValue"=>
                         {"Id"=>"Events",
                          "Max"=>"Inf",
                          "Min"=>"0",
                          "ComplexValue"=>
                          {"Id"=>"Event",
                           "SimpleValue"=>
                           [{"Id"=>"DateTime",
                             "Validation"=>
                             "(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}.\\d{3})Z"},
                            {"Id"=>"Type", "Validation"=>".*"},
                            {"Id"=>"Id", "Validation"=>".*"},
                            {"Id"=>"Data", "Validation"=>".*"},
                            {"Id"=>"Method", "Validation"=>".*"}]}}}}],
                      :Type=>"Freetext",
                      :UserAnswer=>nil},
                     {:Fullname=>"Question, 1.0.0",
                      :Id=>"a9f56a58-aaaa-eeee-1355-012345678904:3",
                      :Input=>
                      [{"Events"=>nil},
                       {"Instrument"=>
                        {"Label"=>"This wants an email (LabelPosition=left)",
                         "LabelPosition"=>"left",
                         "Validation"=>
                         "[-0-9a-zA-Z.%2B_]%2B@[-0-9a-zA-Z.%2B_]%2B\\.[a-zA-Z]{2,4}",
                         "BoxWidth"=>nil,
                         "BoxHeight"=>nil,
                         "Resizable"=>nil}}],
                      :Output=>
                      [{"Validation"=>
                        {"SimpleValue"=>
                         {"Id"=>"Text",
                          "Validation"=>
                          "[-0-9a-zA-Z.%2B_]%2B@[-0-9a-zA-Z.%2B_]%2B\\.[a-zA-Z]{2,4}"},
                         "MultiValue"=>
                         {"Id"=>"Events",
                          "Max"=>"Inf",
                          "Min"=>"0",
                          "ComplexValue"=>
                          {"Id"=>"Event",
                           "SimpleValue"=>
                           [{"Id"=>"DateTime",
                             "Validation"=>
                             "(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}.\\d{3})Z"},
                            {"Id"=>"Type", "Validation"=>".*"},
                            {"Id"=>"Id", "Validation"=>".*"},
                            {"Id"=>"Data", "Validation"=>".*"},
                            {"Id"=>"Method", "Validation"=>".*"}]}}}}],
                      :Type=>"Freetext",
                      :UserAnswer=>nil},
                     {:Fullname=>"Question, 1.0.0",
                      :Id=>"a9f56a58-aaaa-eeee-1355-012345678904:4",
                      :Input=>[{"Validation"=>nil}, {"Events"=>nil}],
                      :Output=>
                      [{"Validation"=>
                        {"MultiValue"=>
                         [{"Id"=>"Events",
                           "Max"=>"Inf",
                           "Min"=>"0",
                           "ComplexValue"=>
                           {"Id"=>"Event",
                            "SimpleValue"=>
                            [{"Id"=>"DateTime",
                              "Validation"=>
                              "(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}.\\d{3})Z"},
                             {"Id"=>"Type", "Validation"=>".*"},
                             {"Id"=>"Id", "Validation"=>".*"},
                             {"Id"=>"Data", "Validation"=>".*"},
                             {"Id"=>"Method", "Validation"=>".*"}]}},
                          {"Id"=>"Contexts",
                           "Max"=>"Inf",
                           "Min"=>"0",
                           "ComplexValue"=>
                           {"Id"=>"Context",
                            "SimpleValue"=>
                            [{"Id"=>"DateTime",
                              "Validation"=>
                              "(\\d{4}-\\d{2}-\\d{2})T(\\d{2}:\\d{2}:\\d{2}.\\d{3})Z"},
                             {"Id"=>"Type", "Validation"=>".*"},
                             {"Id"=>"Data", "Validation"=>".*"}]}}]}},
                       {"Value"=>{"Events"=>nil, "Context"=>{"Type"=>nil, "Data"=>nil}}}],
                      :Type=>"Monitor",
                      :UserAnswer=>nil}]
    assert_equal x, expected
  end
end
