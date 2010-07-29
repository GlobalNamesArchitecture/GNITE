Then /^I should see a node "([^"]*)" at the root level in my master tree$/ do |node_text|
  within('.jstree-leaf') do |scope|
    scope.should contain(node_text)
  end
end

When /^I enter "([^"]*)" in the new node and press enter$/ do |text|
  evaluate_script(%{
    var nodeInput = $('.jstree-last input');
    nodeInput.val("#{text}");
    nodeInput.trigger(jQuery.Event("keyup"));
    nodeInput.trigger(jQuery.Event("keypress"));
    nodeInput.trigger(jQuery.Event("keydown"));
    nodeInput.trigger(jQuery.Event("keydown"));
    nodeInput.keypress({which: 13}); //(jQuery.Event("keydown"));
  })
end
