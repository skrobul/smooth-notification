Feature: buffer the 'clear' messages
    As a frequent alerts receipient, I would like to receive aggregated 'clear' messages if they are sent within specified period.

    Scenario: 10 messages sent within THRESHOLD seconds
        Given there are no messages in buffer
        When server sends all 10 messages in roughly the same time
        And all messages are 'clear' messages
        Then messages are aggregated
        And messages are sent out
        And buffer is cleared for next aggregation period

    Scenario: 5 messages sent followed by another 5 messages after THRESHOLD
        Given server sent 5 messages in current period and 2xTHRESHOLD has elapsed
        When it sends additional 5 'clear' messages
        Then first 5 messages are sent as one aggregated message
        And after timer expires second aggregated message is sent

    Scenario: Non-clear message arrives
        Given server sent 10 messages
        When 3 of them are 'clear'
        And 7 of them are 'problem' messages
        Then 7 'problem' messages are sent immediately
        And 'clear' messages are aggregated into one message

