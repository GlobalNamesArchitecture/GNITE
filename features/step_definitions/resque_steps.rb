When "import jobs are run" do
  Timeout.timeout(2) do
    connected = false
    while !connected
      connected = page.has_css?(".juggernaut-connected")
    end
  
    r = Resque::Worker.new(:gnaclr_importer)
    not_empty = true
    When %{pause 1}
    while not_empty
      not_empty = r.process
    end
  end
end

When "merge jobs are run" do
  Timeout.timeout(2) do
    r = Resque::Worker.new(:merge_event)
    not_empty = true
    When %{pause 1}
    while not_empty
      not_empty = r.process
    end
  end
end
