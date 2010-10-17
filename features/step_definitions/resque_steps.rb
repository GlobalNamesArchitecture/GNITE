When "resque jobs are run" do
  r = Resque::Worker.new(:gnaclr_importer)
  not_empty = true
  while not_empty
    not_empty = r.process
  end
end
