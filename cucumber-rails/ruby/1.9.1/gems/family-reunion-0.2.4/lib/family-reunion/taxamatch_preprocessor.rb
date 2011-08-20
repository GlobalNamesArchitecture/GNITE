class FamilyReunion
  class TaxamatchPreprocessor

    def initialize(cache)
      @cache = cache
    end

    def get_match_candidates(list1, list2)
      match_candidates = {:uninomials => {}, :binomials => {}, :trinomials => {}}
      partitioned_names1 = partition_canonicals(list1)
      partitioned_names2 = partition_canonicals(list2)
      [:uninomials, :binomials, :trinomials].each do |bucket|
        candidates = self.send("process_#{bucket}", partitioned_names1[bucket], partitioned_names2[bucket])
        match_candidates[bucket].merge!(candidates)                      
      end
      match_candidates
    end

    def partition_canonicals(canonicals)
      partitions = { :uninomials => [], :binomials => [], :trinomials => [], :multinomials => [] }
      canonicals.each do |name|
        words = name.split(' ')
        key = case words.size
              when 1
                :uninomials
              when 2
                :binomials
              when 3
                :trinomials
              else
                :multinomials
              end
        partitions[key] << [name, words]
      end
      partitions
    end

    def process_uninomials(names1, names2)
      names1.inject({}) do |res, n1|
        names2.each do |n2|
          if similar_words?(n1[1][0], n2[1][0])
            res.has_key?(n1[0]) ? res[n1[0]][:candidates] << n2 : res[n1[0]] = { :words => n1[1], :candidates => [n2] }
          end
        end
        res
      end
    end

    def process_binomials(names1, names2)
      names1.inject({}) do |res, n1|
        names2.each do |n2|
          if similar_words?(n1[1][0], n2[1][0]) && similar_words?(n1[1][1], n2[1][1])
            res.has_key?(n1[0]) ? res[n1[0]][:candidates] << n2 : res[n1[0]] = { :words => n1[1], :candidates => [n2] }
          end
        end
        res
      end
    end
    
    def process_trinomials(names1, names2)
      names1.inject({}) do |res, n1|
        names2.each do |n2|
          if similar_words?(n1[1][0], n2[1][0]) && similar_words?(n1[1][1], n2[1][1]) && similar_words?(n1[1][2], n2[1][2])
            res.has_key?(n1[0]) ? res[n1[0]][:candidates] << n2 : res[n1[0]] = { :words => n1[1], :candidates => [n2] }
          end
        end
        res
      end
    end

    def similar_words?(word1, word2)
      raise RuntimeError unless (word1.is_a?(String) && word2.is_a?(String))
      
      key = [word1, word2].sort.join(':')
      cached = @cache.similar_words[key]
      return cached if cached != nil
        
      are_similar = false
      if word1 == word2
        are_similar = true
      else 
        letters1 = get_letters(word1)
        letters2 = get_letters(word2)
        symmertric_difference = (letters1 - letters2) + (letters2 - letters1)
        similar_letters = symmertric_difference.size.to_f/(letters1.size + letters2.size) <= 0.3
        similar_length = (word1.size - word2.size).abs.to_f/word1.size <= 0.2
        are_similar = similar_letters && similar_length
      end 
      @cache.similar_words[key] = are_similar
      are_similar
    end

    def get_letters(word)
      letters = @cache.word_letters[word]
      if letters == nil
        letters = word.split('').uniq
        @cache.word_letters[word] = letters
      end
      letters
    end
    
  end
end
