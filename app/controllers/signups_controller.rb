class SignupsController < ApplicationController

  def new
    @signup = Signup.new
  end
  
  def create
    @signup = Signup.new(post_params)

    if @signup.valid?
      message = `curl -s --user api:key-636ich94x0vbm0s7hczbsbl-3kyqhax8 \
          https://api.mailgun.net/v2/lists/partychicks@rs74511.mailgun.org/members \
          -F subscribed=True \
          -F address='#{@signup.email}' \
          -F name='#{@signup.first_name} #{@signup.last_name}'`
      response = JSON.parse(message)
      
      Rails.logger.error "response['message']: #{response['message'].inspect}"
      
      if response['message'].match(/Address already exists/)
      
        flash.now[:notice]  = "Oh no! Email address already exists!" 
        render 'new'
      else
        flash[:alert] = "Mailing list member has been created"
        @signup.save   
        redirect_to @signup
      end
    else
      render 'new'
    end
  end
  
  def index
    @signups = Signup.all
  end
  
  def show
    @signup = Signup.find(params[:id])
  end
  
  def destroy
    @signup = Signup.find(params[:id])
    @signup.destroy

    redirect_to signups_path
  end

  private
    def post_params
      Rails.logger.error "#{params.inspect} inspect"
      params.require(:signup).permit(:first_name, :last_name, :email)
    end
end