When "import jobs are run" do
  connected = false
  while !connected
    connected = page.has_css?(".juggernaut-connected")
  end

  r = Resque::Worker.new(:gnaclr_importer)
  not_empty = true
  while not_empty
    not_empty = r.process
  end

end

When "merge jobs are run" do
  r = Resque::Worker.new(:merge_event)
  not_empty = true
  while not_empty
    not_empty = r.process
  end
end
