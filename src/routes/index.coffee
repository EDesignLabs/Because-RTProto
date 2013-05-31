###
GET home page.
###
exports.index = (req, res) ->
  res.render "index",
    title: "Because RT Prototype"
    clientId: process.env.GOOGLE_API_CLIENT_ID
    data: 'https://docs.google.com/spreadsheet/pub?key=0Ar2Io2uAtw9TdEFvb2t5U3BiZDhQRlNSRjRTY3Q2Rmc&output=html'
