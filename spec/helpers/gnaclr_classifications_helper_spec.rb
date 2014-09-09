require 'spec_helper'

describe GnaclrClassificationsHelper, type: :helper do
  describe "author_line_for_classification" do
    it "should stringify the author name" do
      classification = stub('classification', {
        authors: [
          {'first_name' => 'First', 'last_name' => 'Last',    'email' => 'Email'}
        ]
      })

      helper.author_line_for_classification(classification).should == '<a href="mailto:Email">First Last</a>'
    end

    it "should include emails only when present" do
      classification = stub('classification', {
        authors: [
          {'first_name' => 'First', 'last_name' => 'Last',    'email' => 'Email'},
          {'first_name' => 'No',    'last_name' => 'Address', 'email' => nil}
        ]
      })

      helper.author_line_for_classification(classification).should == '<a href="mailto:Email">First Last</a> and No Address'
    end

    it "should provide a sentence" do
      classification = stub('classification', {
        authors: [
          {'first_name' => 'Alice',   'last_name' => 'Apple',     'email' => 'aapple@example.com'},
          {'first_name' => 'Betty',   'last_name' => 'Blueberry', 'email' => 'bblueberry@example.com'},
          {'first_name' => 'Charles', 'last_name' => 'Cherry',    'email' => 'ccherry@example.com'}
        ]
      })

      helper.author_line_for_classification(classification).should ==
        '<a href="mailto:aapple@example.com">Alice Apple</a>, '+
        '<a href="mailto:bblueberry@example.com">Betty Blueberry</a>, ' +
        'and <a href="mailto:ccherry@example.com">Charles Cherry</a>'
    end
  end
end
