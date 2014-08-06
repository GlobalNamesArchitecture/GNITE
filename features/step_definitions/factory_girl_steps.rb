module FactoryGirlStepHelpers
  def convert_association_string_to_instance(factory_name, assignment)
    attribute, value = assignment.split(':', 2)
    return if value.blank?
    attributes = convert_human_hash_to_attribute_hash(attribute => value.strip)
    factory = FactoryGirl.factory_by_name(factory_name)
    model_class = factory.build_class
    model_class.where(attributes).first or
      FactoryGirl.create(factory_name, attributes)
  end

  def convert_human_hash_to_attribute_hash(human_hash, associations = [])
    human_hash.inject({}) do |attribute_hash, (human_key, value)|
      key = human_key.downcase.gsub(' ', '_').to_sym
      if association = associations.detect {|association| association.name == key }
        value = convert_association_string_to_instance(association.factory, value)
      end
      attribute_hash.merge(key => value)
    end
  end
end

World(FactoryGirlStepHelpers)

FactoryGirl.factories.each do |factory|
  Given /^the following (?:#{factory.human_names.first}|#{factory.human_names.first.pluralize}) exists?:$/ do |table|
    table.hashes.each do |human_hash|
      attributes = convert_human_hash_to_attribute_hash(human_hash, factory.associations)
      FactoryGirl.create(factory.name, attributes)
    end
  end

  Given /^an? #{factory.human_names.first} exists$/ do
    FactoryGirl.create(factory.name)
  end

  Given /^(\\\\d+) #{factory.human_names.first.pluralize} exist$/ do |count|
    count.to_i.times { FactoryGirl.create(factory.name) }
  end

  if factory.build_class.respond_to?(:columns)
    factory.build_class.columns.each do |column|
      human_column_name = column.name.downcase.gsub('_', ' ')
      Given /^an? #{factory.human_names.first} exists with an? #{human_column_name} of "([^"]*)"$/i do |value|
        FactoryGirl.create(factory.name, column.name => value)
      end

      Given /^(\\\\d+) #{factory.human_names.first.pluralize} exist with an? #{human_column_name} of "([^"]*)"$/i do |count, value|
        count.to_i.times { FactoryGirl.create(factory.name, column.name => value) }
      end
    end
  end
end
