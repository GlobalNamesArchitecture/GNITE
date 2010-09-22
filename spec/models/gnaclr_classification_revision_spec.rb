require 'spec_helper'

describe GnaclrClassificationRevision, 'valid' do
  let(:classification) { GnaclrClassification.new }
  let(:attributes) do
    {
      'url'             => 'http://gnaclr.globalnames.org/classification_file/9/64ff3af4018c3e8fd27f5590387fbdc65289e682',
      'tree_id'         => '64ff3af4018c3e8fd27f5590387fbdc65289e682',
      'message'         => 'My revision message',
      'commited_date'   => Time.now.to_s,
      'file_name'       => '853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip',
      'sequence_number' => '1',
      'id'              => '3fjou3foi323f',
      'classification'  => classification
    }
  end

  before do
    Timecop.freeze
  end

  after do
    Timecop.return
  end

  it 'has an url, a tree_id, a message, a commited_date, a file_name and a sequence_number' do
    revision                        = GnaclrClassificationRevision.new(attributes)
    revision.url.should             == 'http://gnaclr.globalnames.org/classification_file/9/64ff3af4018c3e8fd27f5590387fbdc65289e682'
    revision.tree_id.should         == '64ff3af4018c3e8fd27f5590387fbdc65289e682'
    revision.message.should         == 'My revision message'
    revision.commited_date.should   == Time.now.to_s
    revision.file_name.should       == '853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip'
    revision.sequence_number.should == '1'
    revision.id.should              == '3fjou3foi323f'
    revision.classification.should  == classification
  end
end
