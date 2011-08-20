# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{timecop}
  s.version = "0.3.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["John Trupiano"]
  s.date = %q{2010-06-07}
  s.description = %q{A gem providing "time travel" and "time freezing" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call.}
  s.email = %q{jtrupiano@gmail.com}
  s.files = ["test/test_helper.rb", "test/test_time_stack_item.rb", "test/test_timecop.rb", "test/test_timecop_without_date.rb", "test/test_timecop_without_date_but_with_time.rb"]
  s.homepage = %q{http://github.com/jtrupiano/timecop}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{johntrupiano}
  s.rubygems_version = %q{1.6.2}
  s.summary = %q{A gem providing "time travel" and "time freezing" capabilities, making it dead simple to test time-dependent code.  It provides a unified method to mock Time.now, Date.today, and DateTime.now in a single call.}
  s.test_files = ["test/test_helper.rb", "test/test_time_stack_item.rb", "test/test_timecop.rb", "test/test_timecop_without_date.rb", "test/test_timecop_without_date_but_with_time.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
