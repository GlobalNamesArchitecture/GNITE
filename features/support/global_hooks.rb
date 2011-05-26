
Gnite::ResqueHelper.cleanup


###########################
# Reset global state here #
###########################
at_exit do
  Gnite::ResqueHelper.cleanup
end
