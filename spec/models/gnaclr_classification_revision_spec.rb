require 'spec_helper'

describe GnaclrClassificationRevision, 'valid' do
  let(:attributes) do
    {
      'url'       => 'http://gnaclr.globalnames.org/classification_file/9/64ff3af4018c3e8fd27f5590387fbdc65289e682',
      'file_name' => '853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip',
      'tree_id'   => '64ff3af4018c3e8fd27f5590387fbdc65289e682'
    }
  end

  it 'has an url, a file_name, a tree_id and a message' do
    revision                  = GnaclrClassificationRevision.new(attributes)
    revision.url.should       == 'http://gnaclr.globalnames.org/classification_file/9/64ff3af4018c3e8fd27f5590387fbdc65289e682'
    revision.file_name.should == '853437dc-6d9f-4ab5-ba30-5ae006fccae2.gzip'
    revision.tree_id.should   == '64ff3af4018c3e8fd27f5590387fbdc65289e682'
  end

end
