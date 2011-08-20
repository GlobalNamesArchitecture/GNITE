class FamilyReunion
  class Cache
    attr :word_letters, :similar_words

    def initialize
      @word_letters = {}
      @similar_words = {}
      @taxamatch_genus = {}
      @taxamatch_species = {}
    end

  end
end
