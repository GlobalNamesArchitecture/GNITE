When "delayed jobs are run" do
  Delayed::Worker.new.work_off
end
