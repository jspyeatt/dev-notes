# Oauth2 notes
These notes are based on [this video](https://www.youtube.com/watch?v=996OiexHze0).

## Terminology

### Resource Owner
It's you or me. The person sitting in front of the computer who owns the data the application wants to get to. For example, you own your google contacts.

### Client
It's the application that wants access to the resource owner's data.

### Authorization Server
It's the server who has the authority to give the client permission to the data after the resource owner has said it's ok. So the resource owner uses this
service to verify the owner is who they say they are (via login/password). The authorization server then can ask the resource owner, "hey, this application
wants to access your contacts. Is that OK?". Authorization servers can be google, facebook, twitter, whatever can be used for granting access.

### Scopes
This is the list of possible permissions an authorization server makes available. For example read-contacts, add-contacts, delete-contacts are all different scopes.

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
application wants. (read-contacts).
1. The user clicks on the "grant permissions"
1. The authorization server asks the user to log in.
1. The authorization server then prompts the user to ask "This is the list of scopes yelp wants access to. Is this OK?" (Consent)
1. Upon successful login and consent the authorization server redirects back to the redirect URI (yelp.com/callback) with an authorization code. The client can't really do much with the authorization code. 
1. The only thing the application can do with the authorization code is make a call back to the authorization server with the authorization code and exchange it for an access token.
1. So the application asks the authorization server to exchange the authorization code for an access token. The authorization server verifies the authorization token. And provides an access token.
1. Once the application has that access token it is authorized to grab data (contacts) from the resource server using the access token. The resource server recognizes the access token and understands the application is asking for data on behalf of the client (the user).