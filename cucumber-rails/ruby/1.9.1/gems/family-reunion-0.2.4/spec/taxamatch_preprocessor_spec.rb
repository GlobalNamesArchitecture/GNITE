# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe FamilyReunion::TaxamatchPreprocessor do

  before(:all) do
    cache = FamilyReunion::Cache.new
    @tp = FamilyReunion::TaxamatchPreprocessor.new(cache)
  end

  it "should partition canonical names into buckets " do
    words = ['Betula', 'Gibasis consobrina', 'Gibasis consobrina something', 'Mohelnaspis something something vermiformis']
    result = {:uninomials=>[["Betula", ["Betula"]]], :binomials=>[["Gibasis consobrina", ["Gibasis", "consobrina"]]], :trinomials=>[["Gibasis consobrina something", ["Gibasis", "consobrina", "something"]]], :multinomials=>[["Mohelnaspis something something vermiformis", ["Mohelnaspis", "something", "something", "vermiformis"]]]}
    @tp.partition_canonicals(words).should == result
  end

  it "should process uninomials" do
    words1 = ['Betula', 'Plantago', 'Pinus']
    words2 = ['Heracleum', 'Flantago', 'Quercus', 'Plontago']
    words1 = @tp.partition_canonicals(words1)
    words2 = @tp.partition_canonicals(words2)
    res = @tp.process_uninomials(words1[:uninomials], words2[:uninomials])
    res.should == {"Plantago"=>{:words=>["Plantago"], :candidates=>[["Flantago", ["Flantago"]], ["Plontago", ["Plontago"]]]}}
  end

  it "should process binomials" do
    words1 = ['Betula acuminata', 'Betula alba', 'Siebenrockia ponesis', 'Qemetrisauropus princeps'] 
    words2 = ['Betulo ocuminata', 'Betula pubescens', 'Siebenrockia poënsis', 'Qilianochocha corculum']
    words1 = @tp.partition_canonicals(words1)
    words2 = @tp.partition_canonicals(words2)
    res = @tp.process_binomials(words1[:binomials], words2[:binomials])
    res.should == {"Betula acuminata"=>{:words=>["Betula", "acuminata"], :candidates=>[["Betulo ocuminata", ["Betulo", "ocuminata"]]]}, "Siebenrockia ponesis"=>{:words=>["Siebenrockia", "ponesis"], :candidates=>[["Siebenrockia poënsis", ["Siebenrockia", "poënsis"]]]}} 
  end
  
  it "should process binomials" do
    words1 = ['Betula alba acuminata', 'Betula alba vulgaris', 'Siebenrockia ponesis ponesis', 'Qemetrisauropus princeps'] 
    words2 = ['Betulo alba ocuminata', 'Betula pubescens something', 'Siebenrockia poënsis poënsis', 'Qilianochocha corculum']
    words1 = @tp.partition_canonicals(words1)
    words2 = @tp.partition_canonicals(words2)
    res = @tp.process_trinomials(words1[:trinomials], words2[:trinomials])
    res.should == {"Betula alba acuminata"=>{:words=>["Betula", "alba", "acuminata"], :candidates=>[["Betulo alba ocuminata", ["Betulo", "alba", "ocuminata"]]]}, "Siebenrockia ponesis ponesis"=>{:words=>["Siebenrockia", "ponesis", "ponesis"], :candidates=>[["Siebenrockia poënsis poënsis", ["Siebenrockia", "poënsis", "poënsis"]]]}}
  end

  it "should find match candidates" do
    words1 = ['Betula', 'Plantago', 'Pinus', 'Betula acuminata', 'Betula alba', 'Siebenrockia ponesis', 'Qemetrisauropus princeps', 'Betula alba acuminata', 'Betula alba vulgaris', 'Siebenrockia ponesis ponesis', 'Qemetrisauropus princeps', 'Some crazy long name']
    words2 = ['Heracleum', 'Flantago', 'Quercus', 'Plontago', 'Betulo ocuminata', 'Betula pubescens', 'Siebenrockia poënsis', 'Qilianochocha corculum', 'Betulo alba ocuminata', 'Betula pubescens something', 'Siebenrockia poënsis poënsis', 'Qilianochocha corculum']
    @tp.get_match_candidates(words1, words2).should == {:uninomials=>{"Plantago"=>{:words=>["Plantago"], :candidates=>[["Flantago", ["Flantago"]], ["Plontago", ["Plontago"]]]}}, :binomials=>{"Betula acuminata"=>{:words=>["Betula", "acuminata"], :candidates=>[["Betulo ocuminata", ["Betulo", "ocuminata"]]]}, "Siebenrockia ponesis"=>{:words=>["Siebenrockia", "ponesis"], :candidates=>[["Siebenrockia poënsis", ["Siebenrockia", "poënsis"]]]}}, :trinomials=>{"Betula alba acuminata"=>{:words=>["Betula", "alba", "acuminata"], :candidates=>[["Betulo alba ocuminata", ["Betulo", "alba", "ocuminata"]]]}, "Siebenrockia ponesis ponesis"=>{:words=>["Siebenrockia", "ponesis", "ponesis"], :candidates=>[["Siebenrockia poënsis poënsis", ["Siebenrockia", "poënsis", "poënsis"]]]}}}
  end
end
