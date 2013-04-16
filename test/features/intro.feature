Feature: Because RT Proto Introduction
    In order to learn more about the real-time prototype
    As a new student user
    I want to see an inline tutorial about how to use it

    Scenario: See the first hint
        Given I am on the intro screen
        When I click on anything
        Then I see a popup with a hint
