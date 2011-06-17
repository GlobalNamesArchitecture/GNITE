When /^I wait for the websocket to activate$/ do
  loaded = false
  When %{pause 1}
  while !loaded
    loaded = page.has_css?("#master-tree.socket-active")
  end
end

When /^I maximize the chat window$/ do
  page.execute_script("jQuery('#chat-messages-maximize').click();")
end

When /^I enter "([^"]*)" in the chat box and press enter$/ do |text|
  field = find(:css, "#chat-messages-input")
  field.set(text)
  page.execute_script <<-JS
    var e = jQuery.Event("keypress");
    e.which = 13;
    $("#chat-messages-input").trigger(e);
  JS
  sleep 2
end

Then /^I should see a chat message "([^"]*)"$/ do |chat_message|
  page.should have_css("div#chat-messages-scroller>ul>li>span.message:contains('#{chat_message}')")
end