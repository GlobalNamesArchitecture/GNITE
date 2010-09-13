require 'spec_helper'

describe GnaclrClassification, "with remote classifications" do
  let(:expected_classifications) do
    [
      GnaclrClassification.new({
        "title" => "NCBI",
        "authors" => [{ "first_name" => "Dmitry", "last_name" => "Mozzherin", "email" => "dmozzherin@gmail.com"}],
        "description" => "NCBI classification",
        "uuid" => "97d7633b-5f79-4307-a397-3c29402d9311",
        "updated" => Time.parse("Thu Jul 15 20:49:40 UTC 2010"),
        "file_url" => "http://gnaclr.globalnames.org/files/baaa4762cb1ef8118f2c20257a3c27c946f09375/ncbi.tar.gz"
      }),
      GnaclrClassification.new({
        "title" => "Choreutidae Classification",
        "authors" => [{"first_name" => "Jadranka", "last_name" => "Rota", "email" => "jadranka.rota@gmail.com"}],
        "description" => "&lt;p&gt;based on Heppner and Duckworth and new genera published since&lt;/p&gt;",
        "uuid" => "91d08561-b72f-4159-9461-119690b67afa",
        "updated" => Time.parse("Wed May 26 14:57:31 UTC 2010"),
        "file_url" => "http://gnaclr.globalnames.org/files/d6781d6071d25a0e46dcb889d6bd1a40407f1b6e/choreutidae.tar.gz"
      })
    ]
  end

  before do
    response = File.open(File.join(Rails.root, 'spec', 'fixtures', 'gnaclr_classifications.xml')).read
    stub_app = ShamRack.at(GnaclrClassification::URL).stub
    stub_app.register_resource("/classifications?format=xml", response, "application/xml")
  end

  it "should return all the classifications" do
    GnaclrClassification.all.size.should == 2
    GnaclrClassification.all.should == expected_classifications
  end

  it "should find a classification by uuid" do
    GnaclrClassification.find_by_uuid('97d7633b-5f79-4307-a397-3c29402d9311').should == expected_classifications.first
    GnaclrClassification.find_by_uuid('91d08561-b72f-4159-9461-119690b67afa').should == expected_classifications.last
  end
end

describe GnaclrClassification, "attributes" do
  before do
    @updated_time = Time.now
    @attributes = {
      :title       => "Title",
      :authors     => ["Author 1", "Author 2"],
      :description => "Description",
      :updated     => @updated_time,
      :uuid        => "abcdef-ghij-klmnop",
      :file_url    => 'example.tar.gz'
    }
  end

  it "should have a title, authors, a description, an updated, a uuid, a file URL, and a constructor that accepts a hash" do

    gnaclr_classification = GnaclrClassification.new(@attributes)

    gnaclr_classification.attributes.should  == @attributes

    gnaclr_classification.title.should       == "Title"
    gnaclr_classification.authors.should     == ["Author 1", "Author 2"]
    gnaclr_classification.description.should == "Description"
    gnaclr_classification.updated.should     == @updated_time
    gnaclr_classification.uuid.should        == "abcdef-ghij-klmnop"
    gnaclr_classification.file_url.should    == "example.tar.gz"
  end

  it "should test equality on attributes" do
    one = GnaclrClassification.new(@attributes)
    another = GnaclrClassification.new(@attributes)

    one.should == another
  end

  it "should provide uuid for #to_param" do
    GnaclrClassification.new(:uuid => "uuid").to_param.should == "uuid"
  end

  it "should default its revisions to []" do
    GnaclrClassification.new.revisions.should == []
  end
end
