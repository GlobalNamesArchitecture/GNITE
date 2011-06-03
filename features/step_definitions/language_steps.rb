# coding: utf-8

When /^languages have been imported$/ do
  Factory(:language, :name => 'English', :iso_639_1 => 'en', :iso_639_2 => 'eng', :iso_639_3 => 'eng', :native => 'English')
  Factory(:language, :name => 'Portuguese', :iso_639_1 => 'pt', :iso_639_2 => 'por', :iso_639_3 => 'por', :native => 'Português')
end