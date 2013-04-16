module.exports = ->
    @World = require("../support/world").World

    @Given /^I am on the intro screen$/, (callback)->
        @visit '/', callback

    @When /^I click on anything$/, (callback)->
        callback()

    @Then /^I see a popup with a hint$/, (callback)->
        callback.pending()
