Then /^I should see a chat message "([^"]*)"$/ do |chat_message|
  page.should have_css("div#chat-messages-scroller>ul>li>span.message:contains('#{chat_message}')")
end

When /^I wait for the websocket to activate$/ do
  loaded = false
  When %{pause 1}
  while !loaded
    loaded = page.has_css?("#master-tree.socket-active")
  end
end