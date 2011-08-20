require "spec_helper"

describe FactoryGirl::AttributeList, "#define_attribute" do
  let(:static_attribute)  { FactoryGirl::Attribute::Static.new(:full_name, "value") }
  let(:dynamic_attribute) { FactoryGirl::Attribute::Dynamic.new(:email, lambda {|u| "#{u.full_name}@example.com" }) }

  it "maintains a list of attributes" do
    subject.define_attribute(static_attribute)
    subject.to_a.should == [static_attribute]

    subject.define_attribute(dynamic_attribute)
    subject.to_a.should == [static_attribute, dynamic_attribute]
  end

  it "raises if an attribute has already been defined" do
    expect {
      2.times { subject.define_attribute(static_attribute) }
    }.to raise_error(FactoryGirl::AttributeDefinitionError, "Attribute already defined: full_name")
  end
end

describe FactoryGirl::AttributeList, "#attribute_defined?" do
  let(:static_attribute)                    { FactoryGirl::Attribute::Static.new(:full_name, "value") }
  let(:callback_attribute)                  { FactoryGirl::Attribute::Callback.new(:after_create, lambda { }) }
  let(:static_attribute_named_after_create) { FactoryGirl::Attribute::Static.new(:after_create, "funky!") }

  it "knows if an attribute has been defined" do
    subject.attribute_defined?(static_attribute.name).should == false

    subject.define_attribute(static_attribute)

    subject.attribute_defined?(static_attribute.name).should == true
    subject.attribute_defined?(:undefined_attribute).should == false
  end

  it "doesn't reference callbacks" do
    subject.define_attribute(callback_attribute)

    subject.attribute_defined?(:after_create).should == false

    subject.define_attribute(static_attribute_named_after_create)
    subject.attribute_defined?(:after_create).should == true
  end
end

describe FactoryGirl::AttributeList, "#add_callback" do
  let(:proxy_class) { mock("klass") }
  let(:proxy) { FactoryGirl::Proxy.new(proxy_class) }
  let(:valid_callback_names) { [:after_create, :after_build, :after_stub] }
  let(:invalid_callback_names) { [:before_create, :before_build, :bogus] }


  it "allows for defining adding a callback" do
    subject.add_callback(:after_create) { "Called after_create" }

    subject.first.name.should == :after_create

    subject.first.add_to(proxy)
    proxy.callbacks[:after_create].first.call.should == "Called after_create"
  end

  it "allows valid callback names to be assigned" do
    valid_callback_names.each do |callback_name|
      expect do
        subject.add_callback(callback_name) { "great name!" }
      end.to_not raise_error(FactoryGirl::InvalidCallbackNameError)
    end
  end

  it "raises if an invalid callback name is assigned" do
    invalid_callback_names.each do |callback_name|
      expect do
        subject.add_callback(callback_name) { "great name!" }
      end.to raise_error(FactoryGirl::InvalidCallbackNameError, "#{callback_name} is not a valid callback name. Valid callback names are [:after_build, :after_create, :after_stub]")
    end
  end
end

describe FactoryGirl::AttributeList, "#apply_attributes" do
  let(:full_name_attribute) { FactoryGirl::Attribute::Static.new(:full_name, "John Adams") }
  let(:city_attribute)      { FactoryGirl::Attribute::Static.new(:city, "Boston") }
  let(:email_attribute)     { FactoryGirl::Attribute::Dynamic.new(:email, lambda {|model| "#{model.full_name}@example.com" }) }
  let(:login_attribute)     { FactoryGirl::Attribute::Dynamic.new(:login, lambda {|model| "username-#{model.full_name}" }) }

  it "prepends applied attributes" do
    subject.define_attribute(full_name_attribute)
    subject.apply_attributes([city_attribute])
    subject.to_a.should == [city_attribute, full_name_attribute]
  end

  it "moves non-static attributes to the end of the list" do
    subject.define_attribute(full_name_attribute)
    subject.apply_attributes([city_attribute, email_attribute])
    subject.to_a.should == [city_attribute, full_name_attribute, email_attribute]
  end

  it "maintains order of non-static attributes" do
    subject.define_attribute(full_name_attribute)
    subject.define_attribute(login_attribute)
    subject.apply_attributes([city_attribute, email_attribute])
    subject.to_a.should == [city_attribute, full_name_attribute, email_attribute, login_attribute]
  end

  it "overwrites attributes that are already defined" do
    subject.define_attribute(full_name_attribute)
    attribute_with_same_name = FactoryGirl::Attribute::Static.new(:full_name, "Benjamin Franklin")

    subject.apply_attributes([attribute_with_same_name])
    subject.to_a.should == [attribute_with_same_name]
  end
end
