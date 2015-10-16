class ApiV1::TestController < ApiV1::BaseController
  skip_before_action :verify_authenticity_token
  before_filter :require_user, :only => [:show, :create, :destroy, :update]
  
  def index
    @tests = Test.all
  end
  
  def show
    @test = Test.find(params[:id])
    authorize!(:read, @test || current_user)
  end
  
  def create
    @test = Test.new(params[:test])
    if @test.save
      render 'show', :status => :created
    else
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def update
    @test = Test.find(params[:id])
    authorize!(:read, @test || current_user)
    if @test.update(test_params)
      render 'show', :status => :ok
    else
      render 'errors', :status => :unprocessable_entity
    end
  end
  
  def destroy
    @test = Test.find(params[:id])
    @test.destroy
  end
  
  private

    def test_params
      # It's mandatory to specify the nested attributes that should be whitelisted.
      # If you use `permit` with just the key that points to the nested attributes hash,
      # it will return an empty hash.
      params.require(:test).permit(:title, :text)
      # has_many :pets
      # params.require(:person).permit(:name, :age, pets_attributes: [ :name, :category ])
    end
  
end
