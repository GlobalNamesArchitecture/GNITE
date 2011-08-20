require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FamilyReunion::FuzzyMatcher do
  before(:all) do
    @conf = FamilyReunion::Spec::Config
    @tw = FamilyReunion::TaxamatchWrapper.new
    @primary_valid_names = @conf.valid_names_primary - @conf.valid_names_secondary
    @secondary_valid_names = @conf.valid_names_secondary - @conf.valid_names_primary 
  end

  it "should be able to match lists of canonical names" do
    res = @tw.match_canonicals_lists(@primary_valid_names, @secondary_valid_names)
    res.should == {"Pachycondlya solitaria"=>["Pachycondyla solitaria"], "Technomyrmex pallipes"=>["Technomyrmex pilipes"], "Crematogaster obscurata"=>["Crematogaster obscurior"]}
  end

  it "should be able to match nodes" do
    res = @tw.match_nodes(@conf.nodes_to_match)
    res.should == [[{:id=>"invasiveants:tid:1453", :path=>["Formicidae", "Pachycondlya", "Pachycondlya solitaria"], :path_ids=>["invasiveants:tid:1381", "invasiveants:tid:1452", "invasiveants:tid:1453"], :rank=>"species", :valid_name=>{:name=>"Pachycondlya solitaria (Smith, F. 1860)", :canonical_name=>"Pachycondlya solitaria", :type=>"valid", :status=>nil}, :synonyms=>[], :name_to_match=>"Pachycondlya solitaria (Smith, F. 1860)"}, [{:id=>"hex10354887", :path=>["Formicidae", "Pachycondyla", "Pachycondyla solitaria"], :path_ids=>["hex100521", "hex1022882", "hex10354887"], :rank=>"species", :valid_name=>{:name=>"Pachycondyla solitaria (Smith, 1860)", :canonical_name=>"Pachycondyla solitaria", :type=>"valid", :status=>"accepted"}, :synonyms=>[], :name_to_match=>"Pachycondyla solitaria (Smith, 1860)"}]]]
  end

end
