require 'spec_helper'

describe GnaclrClassification, "with remote classifications" do
  let(:expected_classifications) do
    [
      GnaclrClassification.new({
        "title"       => "Spider Classification",
        "authors"     => [{ "first_name" => "David", "last_name" => "Shorthouse", "email" => "dshorthouse@eol.org"}],
        "description" => "paraThis is a sample classification used as a template for inclusion in the Global Names Architecture Classification and List Repository.",
        "uuid"        => "853437dc-6d9f-4ab5-ba30-5ae006fccae2",
        "updated"     => Time.parse("Tue Sep 14 04:11:40 UTC 2010"),
        "file_url"    => "http://gnaclr.globalnames.org/files/853437dc-6d9f-4ab5-ba30-5ae006fccae2/853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip"
      }),
      GnaclrClassification.new({
        "title"       => "Index Fungorum",
        "authors"     => [{"first_name" => "Paul", "last_name" => "Kirk", "email" => "p.kirk@cabi.org"}],
        "description" => "Classification of Fungi",
        "uuid"        => "a9995ace-f04f-49e2-8e14-4fdbc810b08a",
        "updated"     => Time.parse("Wed Sep 08 15:08:05 UTC 2010"),
        "file_url"    => "http://gnaclr.globalnames.org/files/a9995ace-f04f-49e2-8e14-4fdbc810b08a/index_fungorum.tar.gz"
      })
    ]
  end

  before do
    response = File.open(File.join(Rails.root, 'spec', 'fixtures', 'gnaclr_classifications.xml')).read
    stub_app = ShamRack.at(GnaclrClassification::URL).stub
    stub_app.register_resource("/classifications?format=xml", response, "application/xml")
  end

  it "returns all the classifications" do
    GnaclrClassification.all.size.should == 2
    GnaclrClassification.all.should == expected_classifications
  end

  it "finds a classification by uuid" do
    GnaclrClassification.find_by_uuid('853437dc-6d9f-4ab5-ba30-5ae006fccae2').should == expected_classifications.first
    GnaclrClassification.find_by_uuid('a9995ace-f04f-49e2-8e14-4fdbc810b08a').should == expected_classifications.last
  end
end

describe GnaclrClassification, "attributes" do
  let(:attributes) do
    {
      :title       => "Title",
      :authors     => ["Author 1", "Author 2"],
      :description => "Description",
      :updated     => @updated_time,
      :uuid        => "abcdef-ghij-klmnop",
      :file_url    => 'example.tar.gz'
    }
  end
  before do
    @updated_time  = Time.now
  end

  it "has a title, authors, a description, an updated, a uuid, a file URL and a constructor that accepts a hash" do
    gnaclr_classification = GnaclrClassification.new(attributes)

    gnaclr_classification.attributes.should  == attributes

    gnaclr_classification.title.should       == "Title"
    gnaclr_classification.authors.should     == ["Author 1", "Author 2"]
    gnaclr_classification.description.should == "Description"
    gnaclr_classification.updated.should     == @updated_time
    gnaclr_classification.uuid.should        == "abcdef-ghij-klmnop"
    gnaclr_classification.file_url.should    == "example.tar.gz"
  end

  it "tests equality on attributes" do
    one     = GnaclrClassification.new(attributes)
    another = GnaclrClassification.new(attributes)

    one.should == another
  end

  it "provides uuid for #to_param" do
    GnaclrClassification.new(:uuid => "uuid").to_param.should == "uuid"
  end

  it "defaults its revisions to []" do
    GnaclrClassification.new.revisions.should == []
  end
end
