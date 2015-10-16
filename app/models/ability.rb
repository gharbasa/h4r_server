class Ability
  include CanCan::Ability
  
  def initialize(user)
    alias_action :create, :read, :update, :destroy, :to => :crud
    #user ||= User.new # guest user (not logged in)
    if user.admin?
      can :manage, :all
    else
      can :read, :all
      #can :crud, User
    end
  end
end