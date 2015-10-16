class Usersession < Authlogic::Session::Base
  # specify configuration here, such as:
  # logout_on_timeout true
  # ...many more options in the documentation
  authenticate_with User
  logout_on_timeout true
end