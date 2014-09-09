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
        "file_url"    => "http://gnaclr.globalnames.org/files/853437dc-6d9f-4ab5-ba30-5ae006fccae2/853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip",
        "revisions"   => ["url"        => "http://gnaclr.globalnames.org/classification_file/9/64ff3af4018c3e8fd27f5590387fbdc65289e682",
                           "message"   => "2010-09-14 at 12:11:40 AM",
                           "file_name" => "853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip",
                           "tree_id"   => "64ff3af4018c3e8fd27f5590387fbdc65289e682"]
      }),
      GnaclrClassification.new({
        "title"       => "Index Fungorum",
        "authors"     => [{"first_name" => "Paul", "last_name" => "Kirk", "email" => "p.kirk@cabi.org"}],
        "description" => "Classification of Fungi",
        "uuid"        => "a9995ace-f04f-49e2-8e14-4fdbc810b08a",
        "updated"     => Time.parse("Wed Sep 08 15:08:05 UTC 2010"),
        "file_url"    => "http://gnaclr.globalnames.org/files/a9995ace-f04f-49e2-8e14-4fdbc810b08a/index_fungorum.tar.gz",
        "revisions"   => [{"url"       => "http://gnaclr.globalnames.org/classification_file/8/45f5a87e1182c90c3ed98f3a52f45b58f0ab6380",
                           "message"   =>  "2010-09-08 at 11:17:42 AM",
                           "file_name" => "index_fungorum.tar.gz",
                           "tree_id"   => "45f5a87e1182c90c3ed98f3a52f45b58f0ab6380"},
                          {"url"       => "http://gnaclr.globalnames.org/classification_file/8/0fb47e2f984942d7f034ddeb43d86aef2552b360",
                           "message"   => "2010-09-08 at 11:08:05 AM",
                           "file_name" => "index_fungorum.tar.gz",
                           "tree_id"   => "0fb47e2f984942d7f034ddeb43d86aef2552b360"}]
      })
    ]
  end

  before do
    response = File.open(File.join(Rails.root, 'spec', 'fixtures', 'gnaclr_classifications.xml')).read
    stub_app = ShamRack.at(GnaclrClassification::URL).stub
    stub_app.register_resource("/classifications?format=xml", response, "application/xml")
  end

  it "returns all the classifications" do
    classifications = GnaclrClassification.all
    classifications.size.should == 2
    classifications.should      == expected_classifications
  end

  it "finds a classification by uuid" do
    GnaclrClassification.find_by_uuid('853437dc-6d9f-4ab5-ba30-5ae006fccae2').should == expected_classifications.first
    GnaclrClassification.find_by_uuid('a9995ace-f04f-49e2-8e14-4fdbc810b08a').should == expected_classifications.last
  end
end

describe GnaclrClassification, "attributes" do
  let(:attributes) do
    {
      title: "Title",
      authors: ["Author 1", "Author 2"],
      description: "Description",
      updated: Time.now,
      uuid: "abcdef-ghij-klmnop",
      file_url: 'example.tar.gz'
    }
  end

  let(:revision_1) do
    { sequence_number: 1,
      message: 'first',
      tree_id: '123',
      file_name: 'first_file_name',
      id: 'abcdef123',
      committed_date: 1.day.ago,
      url: 'first_url' }
  end
  let(:revision_2) do
    { sequence_number: 2,
      message: 'second',
      tree_id: '234',
      file_name: 'second_file_name',
      id: '123abcdef',
      committed_date: 2.days.ago,
      url: 'second_url' }
  end

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  it "has a title, authors, a description, an updated, a uuid, a file URL, revisions and a constructor that accepts a hash" do
    gnaclr_classification = GnaclrClassification.new(attributes)
    gnaclr_classification.add_revision_from_attributes(revision_1)
    gnaclr_classification.add_revision_from_attributes(revision_2)

    gnaclr_classification.attributes.should  == attributes.merge(revisions: [revision_1, revision_2])

    gnaclr_classification.title.should       == "Title"
    gnaclr_classification.authors.should     == ["Author 1", "Author 2"]
    gnaclr_classification.description.should == "Description"
    gnaclr_classification.updated.should     == Time.now
    gnaclr_classification.uuid.should        == "abcdef-ghij-klmnop"
    gnaclr_classification.file_url.should    == "example.tar.gz"
  end

  it "tests equality on attributes" do
    one     = GnaclrClassification.new(attributes)
    another = GnaclrClassification.new(attributes)

    one.should == another
  end

  it "provides uuid for #to_param" do
    GnaclrClassification.new(uuid: "uuid").to_param.should == "uuid"
  end

  it "defaults its revisions to []" do
    GnaclrClassification.new.revisions.should == []
  end
end

describe GnaclrClassification, 'adding a revision' do
  subject do
    GnaclrClassification.new(
      title: "Title",
      authors: ["Author 1", "Author 2"],
      description: "Description",
      uuid: "abcdef-ghij-klmnop",
      file_url: 'example.tar.gz'
      )
  end

  let(:revision_attributes) do
    { url: 'http://gnaclr.globalnames.org',
      file_name: 'example.tgz',
      tree_id: 'some id',
      message: 'revision message',
      id: 'abcdef123',
      committed_date: Time.now,
      sequence_number: 1 }
  end

  it 'accepts a revision when it has no revisions' do
    subject.add_revision_from_attributes(revision_attributes)
    subject.revisions.count.should == 1
    subject.revisions.first.to_hash.should == revision_attributes
  end

  it "sets the revision's classification to itself" do
    subject.add_revision_from_attributes(revision_attributes)
    subject.revisions.first.classification.should == subject
  end

  it 'accepts a revision when it already has revisions' do
    subject.add_revision_from_attributes(revision_attributes)
    subject.add_revision_from_attributes(revision_attributes)
    subject.revisions.count.should == 2
  end
end

describe GnaclrClassification, 'with two revisions' do
  subject do
    GnaclrClassification.new(
      title: "Title",
      authors: ["Author 1", "Author 2"],
      description: "Description",
      uuid: "abcdef-ghij-klmnop",
      file_url: 'example.tar.gz'
      )
  end

  before do
    2.times { subject.add_revision_from_attributes({}) }
  end

  it 'returns 2 for revision_count' do
    subject.revision_count.should == 2
  end

end
