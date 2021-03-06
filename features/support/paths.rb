module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name

    when /the home\s?page/
      '/'

    # Add more mappings here.
    when /the sign up page/i
      new_user_registration_path
    when /the sign in page/i
      new_user_session_path
    when /the password reset request page/i
      new_user_password_path
    when /the resend confirmation page/i
      new_user_confirmation_path
    when /the resend unlock instructions page/i
      new_user_unlock_path
    when /the master tree index page/i
      master_trees_path
    when /the edit user settings page/i
      edit_user_registration_path
    when /the master tree page for "(.+)"/i
      tree = MasterTree.find_by_title($1)
      master_tree_path(tree.id)
    when /the edit history page for "(.+)"/i
      tree = MasterTree.find_by_title($1)
      master_tree_edits_path(tree.id)
    when /the merge events page for "(.+)"/i
      tree = MasterTree.find_by_title($1)
      master_tree_merge_events_path(tree.id)
    when /the merge results page for "(.+)"/i
      tree = MasterTree.find_by_title($1)
      merge_event = MergeEvent.where(master_tree_id: tree.id).first
      master_tree_merge_event_path(tree.id, merge_event.id)
    when /the edit master tree page for "(.+)"/i
      tree = MasterTree.find_by_title($1)
      edit_master_tree_path(tree.id)
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      begin
        page_name =~ /the (.*) page/
        path_components = $1.split(/\s+/)
        self.send(path_components.push('path').join('_').to_sym)
      rescue Object => e
        raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
          "Now, go and add a mapping in #{__FILE__}"
      end
    end
  end
end

World(NavigationHelpers)
