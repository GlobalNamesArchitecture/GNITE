class LexicalVariantsController < ApplicationController
  before_filter :authenticate_user!
  load_and_authorize_resource
  skip_authorize_resource :only => :create
  
  def index
    @lexicalable = find_lexicalable
    @lexical_variants = @lexicalable.lexical_variants
  end
  
  def edit
  end
  
  def create
    @lexicalable = find_lexicalable
    if cannot? :update, @lexicalable
      flash[:error] = "Access denied."
      redirect_to root_url
    else
      name = Name.find_or_create_by_name_string(params[:name_string])
      @lexical_variant = LexicalVariant.new(:name => name, :lexicalable => @lexicalable)
      @lexical_variant.save
      respond_to do |format|
        format.json do
          render :json => @lexical_variant
        end
      end
    end
  end
  
  def update
    @lexical_variant.rename(params[:name_string])
    respond_to do |format|
      format.json do
        render :json => @lexical_variant
      end
    end
  end
  
  def destroy
    @lexical_variant.destroy
    respond_to do |format|
      format.json do
        render :json => @lexical_variant
      end
    end
  end
  
  private
  
  def find_lexicalable
    classes ||= []
    params.each do |name, value|
      if name =~ /(.+)_id$/
        classes << $1.classify.constantize.find(value)
      end
    end
    return classes.last
  end
  
end