When "resque jobs are run" do
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
