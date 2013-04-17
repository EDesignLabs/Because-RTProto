define ->
  ###
  Copyright 2013 Google Inc. All Rights Reserved.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  ###
  "use strict"

  ###
  @fileoverview Common utility functionality for Google Drive Realtime API,
  including authorization and file loading. This functionality should serve
  mostly as a well-documented example, though is usable in its own right.
  ###

  ###
  @namespace Realtime client utilities namespace.
  ###
  class RTClient

    ###
    OAuth 2.0 scope for installing Drive Apps.
    @const
    ###
    INSTALL_SCOPE: "https://www.googleapis.com/auth/drive.install"

    ###
    OAuth 2.0 scope for opening and creating files.
    @const
    ###
    FILE_SCOPE: "https://www.googleapis.com/auth/drive.file"

    ###
    OAuth 2.0 scope for accessing the user's ID.
    @const
    ###
    OPENID_SCOPE: "openid"

    ###
    MIME type for newly created Realtime files.
    @const
    ###
    REALTIME_MIMETYPE: "application/vnd.google-apps.drive-sdk"

    ###
    Parses the query parameters to this page and returns them as an object.
    @function
    ###
    constructor: (@window) ->
      ###
      Instance of the query parameters.
      ###
      @params = @getParams()


    ###
    Parses the query parameters to this page and returns them as an object.
    @function
    ###
    getParams: ->
      params = {}
      queryString = @window.location.search
      if queryString

        # split up the query string and store in an object
        paramStrs = queryString.slice(1).split("&")
        i = 0

        while i < paramStrs.length
          paramStr = paramStrs[i].split("=")
          params[paramStr[0]] = unescape(paramStr[1])
          i++
      console.log params
      params

    ###
    Fetches an option from options or a default value, logging an error if
    neither is available.
    @param options {Object} containing options.
    @param key {string} option key.
    @param defaultValue {Object} default option value (optional).
    ###
    getOption: (options, key, defaultValue) ->
      value = (if typeof options[key] is 'undefined' then defaultValue else options[key])
      console.error key + " should be present in the options."  if typeof value is 'undefined'
      console.log value
      value


    ###
    Creates a new Realtime file.
    @param title {string} title of the newly created file.
    @param callback {Function} the callback to call after creation.
    ###
    createRealtimeFile: (title, callback) ->
      gapi.client.load "drive", "v2", =>
        gapi.client.drive.files.insert(resource:
          mimeType: @REALTIME_MIMETYPE
          title: title
        ).execute callback



    ###
    Fetches the metadata for a Realtime file.
    @param fileId {string} the file to load metadata for.
    @param callback {Function} the callback to be called on completion, with signature:

    function onGetFileMetadata(file) {}

    where the file parameter is a Google Drive API file resource instance.
    ###
    getFileMetadata: (fileId, callback) ->
      gapi.client.load "drive", "v2", ->
        gapi.client.drive.files.get(fileId: id).execute callback



    ###
    Parses the state parameter passed from the Drive user interface after Open
    With operations.
    @param stateParam {Object} the state query parameter as an object or null if
    parsing failed.
    ###
    parseState: (stateParam) ->
      try
        stateObj = JSON.parse(stateParam)
        return stateObj
      catch e
        return null


    ###
    Redirects the browser back to the current page with an appropriate file ID.
    @param fileId {string} the file ID to redirect to.
    @param userId {string} the user ID to redirect to.
    ###
    redirectTo: (fileId, userId) ->
      params = []
      params.push "fileId=" + fileId  if fileId
      params.push "userId=" + userId  if userId

      # Naive URL construction.
      @window.location.href = (if params.length is 0 then "/" else ("?" + params.join("&")))

    getRealtimeLoader: (options)->
      @realtimeLoader ?= new @RealtimeLoader(@, options)
      @realtimeLoader


  ###
  Handles authorizing, parsing query parameters, loading and creating Realtime
  documents.
  @constructor
  @param options {Object} options for loader. Four keys are required as mandatory, these are:

  1. "clientId", the Client ID from the APIs Console
  2. "initializeModel", the callback to call when the file is loaded.
  3. "onFileLoaded", the callback to call when the model is first created.

  and one key is optional:

  1. "defaultTitle", the title of newly created Realtime files.
  ###
  class RTClient::RealtimeLoader
    # Initialize configuration variables.
    constructor: (@rtclient, @options) ->
      @onFileLoaded = @rtclient.getOption(@options, "onFileLoaded")
      @initializeModel = @rtclient.getOption(@options, "initializeModel")
      @registerTypes = @rtclient.getOption(@options, "registerTypes", ->
      )
      @autoCreate = @rtclient.getOption(@options, "autoCreate", false) # This tells us if need to we automatically create a file after auth.
      @defaultTitle = @rtclient.getOption(@options, "defaultTitle", "New Realtime File")
      @authorizer = new @rtclient.Authorizer(@rtclient, @options)


    ###
    Starts the loader by authorizing.
    @param callback {Function} afterAuth callback called after authorization.
    ###
    start: (afterAuth) ->

      # Bind to local context to make them suitable for callbacks.
      @authorizer.start =>
        @registerTypes()  if @registerTypes
        afterAuth()  if afterAuth
        @load()



    ###
    Loads or creates a Realtime file depending on the fileId and state query
    parameters.
    ###
    load: ->
      fileId = @rtclient.params["fileId"]
      userId = @authorizer.userId
      state = @rtclient.params["state"]

      # Creating the error callback.
      handleErrors = (e) =>
        if e.type is gapi.drive.realtime.ErrorType.TOKEN_REFRESH_REQUIRED
          @authorizer.authorize()
        else if e.type is gapi.drive.realtime.ErrorType.CLIENT_ERROR
          alert "An Error happened: " + e.message
          @rtclient.window.location.href = "/"
        else if e.type is gapi.drive.realtime.ErrorType.NOT_FOUND
          alert "The file was not found. It does not exist or you do not have read access to the file."
          @rtclient.window.location.href = "/"


      # We have a file ID in the query parameters, so we will use it to load a file.
      if fileId
        gapi.drive.realtime.load fileId, @onFileLoaded, @initializeModel, handleErrors
        return

      # We have a state parameter being redirected from the Drive UI. We will parse
      # it and redirect to the fileId contained.
      else if state
        stateObj = @rtclient.parseState(state)

        # If opening a file from Drive.
        if stateObj.action is "open"
          fileId = stateObj.ids[0]
          userId = stateObj.userId
          @rtclient.redirectTo fileId, userId
          return
      @createNewFileAndRedirect() if @autoCreate


    ###
    Creates a new file and redirects to the URL to load it.
    ###
    createNewFileAndRedirect: ->

      #No fileId or state have been passed. We create a new Realtime file and
      # redirect to it.
      @rtclient.createRealtimeFile @defaultTitle, (file) =>
        if file.id
          @rtclient.redirectTo file.id, @authorizer.userId

        # File failed to be created, log why and do not attempt to redirect.
        else
          console.error "Error creating file."
          console.error file




  ###
  Creates a new Authorizer from the options.
  @constructor
  @param options {Object} for authorizer. Two keys are required as mandatory, these are:

  1. "clientId", the Client ID from the APIs Console
  ###
  class RTClient::Authorizer
    constructor: (@rtclient, @options) ->
      @clientId = @rtclient.getOption(@options, "clientId")

      # Get the user ID if it's available in the state query parameter.
      @userId = rtclient.params["userId"]
      @authButton = document.getElementById(rtclient.getOption(@options, "authButtonElementId"))


    ###
    Start the authorization process.
    @param onAuthComplete {Function} to call once authorization has completed.
    ###
    start: (onAuthComplete) ->
      gapi.load "auth:client,drive-realtime,drive-share", =>
        @authorize onAuthComplete



    ###
    Reauthorize the client with no callback (used for authorization failure).
    @param onAuthComplete {Function} to call once authorization has completed.
    ###
    authorize: (onAuthComplete) =>
      clientId = @clientId
      userId = @userId
      handleAuthResult = (authResult) =>
        if authResult and not authResult.error
          @authButton.disabled = true
          @fetchUserId onAuthComplete
        else
          @authButton.disabled = false
          @authButton.onclick = authorizeWithPopup

      authorizeWithPopup = =>
        gapi.auth.authorize
          client_id: clientId
          scope: [@rtclient.INSTALL_SCOPE, @rtclient.FILE_SCOPE, @rtclient.OPENID_SCOPE]
          user_id: userId
          immediate: false
        , handleAuthResult
        console.log clientId


      # Try with no popups first.
      gapi.auth.authorize
        client_id: clientId
        scope: [@rtclient.INSTALL_SCOPE, @rtclient.FILE_SCOPE, @rtclient.OPENID_SCOPE]
        user_id: userId
        immediate: true
      , handleAuthResult


    ###
    Fetch the user ID using the UserInfo API and save it locally.
    @param callback {Function} the callback to call after user ID has been
    fetched.
    ###
    fetchUserId: (callback) ->
      gapi.client.load "oauth2", "v2", =>
        gapi.client.oauth2.userinfo.get().execute (resp) =>
          @userId = resp.id if resp.id
          callback() if callback

  return {
    RTClient: RTClient
  }
