require 'logger'
require 'json'
require 'taxamatch_rb'
require 'family-reunion/cache'
require 'family-reunion/top_node'
require 'family-reunion/matcher_helper'
require 'family-reunion/exact_matcher'
require 'family-reunion/fuzzy_matcher'
require 'family-reunion/taxamatch_wrapper'
require 'family-reunion/taxamatch_preprocessor'
require 'family-reunion/nomatch_organizer'


class FamilyReunion
  attr :primary_node, :secondary_node, :merges
  attr :primary_valid_names_set, :secondary_valid_names_set
  attr :primary_synonyms_set, :secondary_synonyms_set

  VERSION = open(File.join(File.dirname(__FILE__), '..', 'VERSION')).readline.strip

  def self.logger
    @@logger ||= Logger.new(nil)
  end

  def self.logger=(logger)
    @@logger = logger
  end

  def self.logger_reset
    self.logger = Logger.new(nil)
  end

  def self.logger_write(obj_id, message, method = :info)
    self.logger.send(method, "|%s|%s|" % [obj_id, message])
  end

  def initialize(primary_node, secondary_node)
    @primary_node = FamilyReunion::TopNode.new(primary_node)
    @secondary_node = FamilyReunion::TopNode.new(secondary_node)
    @primary_valid_names_set = Set.new(@primary_node.valid_names_hash.keys)
    @secondary_valid_names_set = Set.new(@secondary_node.valid_names_hash.keys)
    @primary_synonyms_set = Set.new(@primary_node.synonyms_hash.keys)
    @secondary_synonyms_set = Set.new(@secondary_node.synonyms_hash.keys)
    @merges = nil
  end

  def merge
    unless @merges
      @merges = {}
      merge_exact_matches
      merge_fuzzy_matches
      merge_no_matches
      FamilyReunion.logger_write(self.object_id, "Merging is complete")
    end
    @merges
  end

  private

  def merge_exact_matches
    FamilyReunion.logger_write(self.object_id, "Started merging of exact matches")
    ExactMatcher.new(self).merge
  end

  def merge_fuzzy_matches
    FamilyReunion.logger_write(self.object_id, "Started merging of fuzzy matches")
    FuzzyMatcher.new(self).merge
  end

  def merge_no_matches
    FamilyReunion.logger_write(self.object_id, "Started gap filling, adding new species and uninomials")
    NomatchOrganizer.new(self).merge
  end

end
