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
      sign_up_path
    when /the sign in page/i
      sign_in_path
    when /the password reset request page/i
      new_password_path
    when /the master tree index page/i
      trees_path
    when /the edit user settings page for "(.+)"/i
      user = User.find_by_email($1)
      edit_user_path(user.id)
    when /the tree page for "(.+)"/i
      tree = Tree.find_by_title($1)
      tree_path(tree.id)
    when /the edit tree page for "(.+)"/i
      tree = Tree.find_by_title($1)
      edit_tree_path(tree.id)
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
