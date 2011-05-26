require 'spec_helper'

describe Language do
    it { should have_many(:vernacular_names) }
end
