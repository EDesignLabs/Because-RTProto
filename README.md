[![Stories in Ready](https://badge.waffle.io/EDesignLabs/Because-RTProto.png)](http://waffle.io/EDesignLabs/Because-RTProto)  
Because Real-Time Prototype
===========================

Almost entirely made for the lulz.

Set Up
------

* Clone this repo: `git clone git://whatever/the/path/is`
* Have the heroku command line tools installed.
* Create a new heroku app: `heroku apps:create`
* Get a Google API key for their Real Time Drive api: https://code.google.com/apis/console
 * It's helpful to make a Client ID for both your herokuapps subdomain and localhost
* Set an env variable with the API Client Id like so (using your localhost Client ID): `export GOOGLE_API_CLIENT_ID="12345yaddayaddayadda.apps.googleusercontent.com"`
* Set an env variable with a secret string: `export SECRET="thisisnotsosecretbutyougettheidea"`
* Run `foreman start`
* Go to localhost, typically on port 5000, unless the PORT variable has been set otherwise: `open http://localhost:5000`
* Set the env varible for the Client ID on heroku: `heroku config:set GOOGLE_API_CLIENT_ID="12345yaddayaddayadda.apps.googleusercontent.com"`
* And also set the secret: `heroku config:set SECRET="thisisnotsosecretbutyougettheidea"`
