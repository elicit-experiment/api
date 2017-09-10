
# Testing Doorkeeper/Devise with minitest and Rails 5

[Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper), [Devise](https://github.com/plataformatec/devise) with [Devise-Doorkeper](https://github.com/betterup/devise-doorkeeper/) to glue them together are good solutions to create an authorization/authentication with Oauth in a Rails (5) API server.  Testing them together was tricky.  Here's what worked for me, using minitest.

## Fixtures

First, we need to set up a user and an `oauth_application` in the DB.  So we create the following fixtures:

`oauth_applications.yml`:
```yaml
 test_app:
  name: "test_app"
  uid: one
  secret: "tell no one"
  scopes: "public"

  redirect_uri: "https://localhost"
  created_at: <%= 5.day.ago.to_s(:db) %>
  updated_at: <%= 5.day.ago.to_s(:db) %>
  ```

`users.yml`:
```yaml
one:
  email: MyString
  anonymous: 
  role: MyString

two:
  email: MyString
  anonymous: 
  role: MyString
```

## Test

```ruby
  setup do
    @user = users(:one)
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    @token.save!
    @headers = { :Authorization => "Bearer #{@token.token}"}
  end
```

(you can probably just create a fixture for the token too; I expected to modify the token in different tests)

Then you write the test like so:

```ruby
  test "should get index" do
    get my_controller_url, as: :json, :headers => @headers
    assert_response :success
  end
```

## Details

This is what's needed if you protect your controller with `before_action :authenticate_user!`, using `devise-doorkeeper`. If all you need straight doorkeeper, i.e. with `before_action :doorkeeper_authorize!`, you don't need the headers:

```ruby
  setup do
    @user = users(:one)
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    @token.save!
  end
```

and in the test:

```ruby
  test "should get index" do
    get my_controller_url, as: :json
    assert_response :success
  end
```

Alternatively, you can avoid even saving the token to the DB if you stub out `doorkeeper_token` using [Mocha]():

```ruby
  setup do
    @study_definition = study_definitions(:one)
    @user = users(:one)
    @dk_app = oauth_applications(:test_app)
    @token = Doorkeeper::AccessToken.new(application_id: @dk_app.id, resource_owner_id: @user.id, expires_in: 2.hours, scopes: :public, created_at: 2.seconds.ago)
    StudyDefinitionsController.any_instance.stubs(:doorkeeper_token).returns(@token)
  end
```

and in the test:

```ruby
  test "should get index" do
    get my_controller_url, as: :json
    assert_response :success
  end
```


