When "delayed jobs are run" do
  Delayed::Worker.new(:quiet => true).work_off
end
