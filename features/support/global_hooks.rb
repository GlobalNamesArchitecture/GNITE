
Gnite::ResqueHelper.cleanup
Gnite::DbData.populate


###########################
# Reset global state here #
###########################
at_exit do
  Gnite::ResqueHelper.cleanup
end
