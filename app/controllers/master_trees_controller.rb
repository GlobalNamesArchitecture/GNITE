class MasterTreesController < ApplicationController
  before_filter :authenticate

  def index
    @master_trees = current_user.master_trees.by_title
  end

  def new
    @master_tree = MasterTree.new(:title => 'New Working Tree')
    @master_tree.user = current_user
    @master_tree.save

    redirect_to master_tree_url(@master_tree.id)
  end

  def show
    @master_tree = MasterTree.find(params[:id])
    user_details = current_user.serializable_hash(:except => [:encrypted_password, :confirmation_token, :remember_token, :salt, :email_confirmed]).to_json
    message = "{\"subject\" : \"member-login\", \"message\" : \"\", \"user\" : " + user_details + ", \"time\" : \"" + Time.new.to_s + "\" }"
    Juggernaut.publish("tree_" + @master_tree.id.to_s, message)
  end

  def edit
    @master_tree = MasterTree.find(params[:id])
  end

  def update
    if params[:cancel]
      redirect_to master_tree_url(params[:id])
    else
      @master_tree = MasterTree.find(params[:id])
      @master_tree.update_attributes(params[:master_tree])
      if @master_tree.save
        if request.xhr?
          render :json => { :status => "OK"}
        else
          flash[:success] = "Working Tree successfully updated"
          redirect_to master_tree_url(@master_tree.id)
        end
      else
        render :edit
      end
    end
  end

  def destroy
    @master_tree = MasterTree.find(params[:id])
    @deleted_tree = DeletedTree.find_by_master_tree_id(params[:id])
    if @master_tree.nuke && @deleted_tree.nuke
      flash[:notice] = 'Tree successfully deleted'
      redirect_to :action => :index
    end
  end

  def publish
    gp = GnaclrPublisher.create!(:master_tree_id => params[:id].to_i)
    Resque.enqueue(GnaclrPublisher, gp.id)
    render :json => { :status => "OK" }
  end
  
  def undo
    action_command = UndoActionCommand.undo(params[:id], request.headers["X-Session-ID"]) 
    action = action_command.nil? ? { :status => "Nothing to undo" } : action_command.serializable_hash(:except => :json_message).merge({ :json_message => JSON.parse(action_command.json_message, :symbolize_keys => true) })
    render :json => action
  end
  
  def redo
    action_command = RedoActionCommand.redo(params[:id], request.headers["X-Session-ID"]) 
    action = action_command.nil? ? { :status => "Nothing to redo" } : action_command.serializable_hash(:except => :json_message).merge({ :json_message => JSON.parse(action_command.json_message, :symbolize_keys => true) })
    render :json => action
  end

end
