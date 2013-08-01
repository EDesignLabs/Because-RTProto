###
Module dependencies.
###
express = require("express")
routes = require("./routes")
http = require("http")
path = require("path")

app = express()

app.configure ->
  app.set "port", process.env.PORT or 3000
  app.set "views", process.cwd() + "/views"
  app.set "view engine", "hjs"
  app.use express.favicon()
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser(process.env.SECRET or "your secret here")
  app.use express.session()
  app.use app.router
  app.use require("stylus").middleware(process.cwd() + "/public")
  app.use express.static(path.join(process.cwd(), "public"))

app.configure "development", ->
  app.use express.errorHandler()

app.get "/", routes.index

http.createServer(app).listen app.get("port"), ->
  console.log process.cwd()
  console.log "Express server listening on port " + app.get("port")
