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

### Resource Server
This is the server which actually holds the data the client/application wants to access. So this is really the API server. For example, the google contacts API.

### Authorization Grant
Is the thing that proves the resource owner is who they say they are and they have given permission for the application to get the data from the resource server
it wants. This grant is issued by the authorization server.

### Redirect URI
When the authorization server issues the grant, it needs to know where to send this grant once approved. This is the redirect URI or callback.

### Access Token
The thing the client really needs to hit the API.

## Actual auth flow
This example flow will give the scenario where yelp wants a user to give them access to the user's contacts on google.

1. Yelp wants access to your contacts so it provides a button "grant permissions".
1. The button is a link to accounts.google.com (the authorization server). The link also includes the redirect URI yelp.com/callback with a response type of `Code` (Code is what type of authorization grant the application wants).
1. 
