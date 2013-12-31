#!/bin/bash

# Path to oauth_sign
oauth_sign="oauth_sign/oauth_sign"

# Oauth creds
consumer_key=""
consumer_secret=""
access_token=""
access_secret=""

# API endpoint. This one posts a tweet and returns JSON
url="https://api.twitter.com/1/statuses/update.json"

# Status (i.e. what to tweet)
status=$*

# Call oauth_sign and make a string for our header.
oauth="$($oauth_sign $consumer_key $consumer_secret $access_token $access_secret POST "$url" status="$status")" 

# Now call cURL to actually do the business. 
curl -H "Authorization:$oauth" -L "$url" --data-urlencode status="$status"
