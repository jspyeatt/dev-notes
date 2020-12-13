# Oauth2 notes
These notes are based on [this video](https://www.youtube.com/watch?v=996OiexHze0).

Special note. Oauth2 was designed for authorization, not authentication. Oauth2 should not be used for authentication. Using it for authentication is bad because
there is no standard way of getting the user's information (What's your name, email etc...). Every implementation is a bit different. No common set of scopes.This was a common misuse pre-2014. OpenId Connect was invented for. See bottom.

## Terminology

### Resource Owner
It's you or me. The person sitting in front of the computer who owns the data the application wants to get to. For example, you own your google contacts.

### Client
It's the application that wants access to the resource owner's data.

### Authorization Server
It's the server who has the authority to give the client permission to the data after the resource owner has said it's ok. So the resource owner uses this
service to verify the owner is who they say they are (via login/password). The authorization server then can ask the resource owner, "hey, this application
wants to access your contacts. Is that OK?". Authorization servers can be google, facebook, twitter, whatever can be used for granting access. The request is going to look something like this:

```
https://accounts.google.com/o/oauth2/v2/auth?client_id=abc123&redirect_uri=https://yelp.com/callback&scope=profile,read-contacts&response_type=code&state=foobar
```
Here's the most important part of this to understand. For yelp to use google for authorization yelp must have done a one-time registration with google basically
say "I have this app, and I want to use it to access your APIs". Google then uses this registration and gives yelp two values. `client_id` which you see above
and `client_secret` which is ONLY used by yelp's backend server when it exchanges an authorization code for an access token. So the client_id is public
because it actually appears on the above URL. But the client_secret is private to ensure an authorization code cannot be highjacked by some other party because
they don't have the client_secret.

### Scopes
This is the list of possible permissions an authorization server makes available. For example read-contacts, add-contacts, delete-contacts, read-calendar are all different scopes.

### Consent
Once the user has successfully logged in to the authorization server, the server presents a consent page to the user asking for permission to the various scopes the application asked for.

### Resource Server
This is the server which actually holds the data the client/application wants to access. So this is really the API server. For example, the google contacts API.

### Authorization Grant
Is the thing that proves the resource owner is who they say they are and they have given permission for the application to get the data from the resource server
it wants. This grant is issued by the authorization server.

### Redirect URI
When the authorization server issues the grant, it needs to know where to send this grant once approved. This is the redirect URI or callback. 

### Access Token
The thing the client really needs to hit the API.

## Actual auth flow for Response Type (Code).
This example flow will give the scenario where yelp wants a user to give them access to the user's contacts on google.

1. Yelp wants access to your contacts so it provides a button "grant permissions".
1. The button is a link to accounts.google.com (the authorization server). The link also includes the redirect URI yelp.com/callback with a response type of `Code` (Code is what type of authorization grant the application wants). The link will also include a list of `scopes` which are the permissions the yelp
application wants. (read-contacts). ex. `https://accounts.google.com/o/oauth2/v2/auth?client_id=abc123&redirect_uri=https://yelp.com/callback&scope=profile,read-contacts&response_type=code&state=foobar`
1. The user clicks on the "grant permissions"
1. The authorization server asks the user to log in.
1. The authorization server then prompts the user to ask "This is the list of scopes yelp wants access to. Is this OK?" (Consent)
1. Upon successful login and consent the authorization server redirects back to the redirect URI (https://yelp.com/callback?code=38947hds05&state=foobar) with an authorization code `38947hds05`. If the user denies access the callback url will be something like `https://yelp.com/callback?error=access_denied&error_description=User did not consent.`
1. The only thing the application can do with the authorization code is make a call back to the authorization server with the authorization code and exchange it for an access token.
1. So the application asks the authorization server to exchange the authorization code for an access token. The authorization server verifies the authorization token. And provides an access token. The request is going to be a POST. For example in google it will include `www.googleapis.com/oauth2/v4/token` with `Content-type: application/x-www-form-urlencoded` and a payload of `code=38947hds05&client_id=abc123&client_secret=YOURSECRET&grant_type=authorization_code`. The response will look something like `{"access_token": "dslgkfh3204978sa", "expires_in": 3920, "token_type": "Bearer"}`. expires_in is in seconds.
1. Once the application has that access token it is authorized to grab data (contacts) from the resource server using the access token. The resource server recognizes the access token and understands the application is asking for data on behalf of the client (the user).

There is a specific reason we get the authorization code and have to ask again for the access token. In networking there are Back Channel (very secure) communications and Front Channel (less secure) communications. An example of a back channel communication would be from your application server to google. This
is back channel because everything is communicated in https. A front channel example would be from your browser to an application server which may not be as secure. So the task that gives you the authorization code (login, consent screen and redirect back to brower) is all front channel communications. The exchange of the authorization code for the access token is back channel. The back channel exchange actually happens between the application server and the authorization server. It's not actually done by the browser. The application server has a secret key.

## Different Authorization Flows
The above flow is the 'Authorization code' flow. It uses front and back channels.

### Implicit Flow
Uses front channel only. This is used when you don't have a back channel. This might occur if you have a pure javascript application which has no backend server.
In this case the initial callback response is not the authorization code, but the access token itself.

This flow is similar to the above narrated Authorization code flow except the Response Type = `token` instead of `code`. And the initial response from the authorization server contains the access token instead of the authorization grant.

### Resource owner password credentials
Back channel only, there is no browser.

### Client credentials
Back channel only, there is no browser. Your application server posting directly to the api service.

## OpenId Connect
OpenID Connect is for authentication, while oauth2 is for authorization. OpenID is really just an extra layer on top of oauth2 from an implementation perspective.

OpenID adds:
1. ID token - 
1. UserInfo endpoint for getting more user information after you've gotten the id token.
1. Standard set of scopes
1. Standarized implementation

### OpenID Connect flow
This piggybacks off the oauth2 flow. When you make a request the only difference is your scope parameter you specify `openid`. Eventually, when your application
exchanges its authorization code with the authorization server the auth server will respond with an access token AND an ID token (JWT). If you subsequently need to get
more information of the user you can hit the `/userinfo` endpoint with the access_token. 
