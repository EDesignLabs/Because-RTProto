###
GET home page.
###
exports.index = (req, res) ->
  res.render "index",
    title: "Because RT Prototype"
    clientId: process.env.GOOGLE_API_CLIENT_ID