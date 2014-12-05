Feature: buffer the 'clear' messages
    As a frequent alerts receipient, I would like to receive aggregated 'clear' messages if they are sent within specified period.

    Scenario: 10 messages sent within THRESHOLD seconds
        Given server sends all 10 messages in roughly the same time
        When all messages are 'clear'
        Then messages are aggregated
        And messages are sent out
        And buffer timer is reset for next countdown

    Scenario: 5 messages sent followed by another 5 messages after THRESHOLD
        Given server sends first 5 messages, waits 2xTHRESHOLD and sends remaining messages
        When all messages are 'clear'
        Then first 5 messages are sent as one aggregated
        And after timer expires second message is sent

    Scenario: Non-clear message arrives
        Given server sends 10 messages
        When 3 of them are 'clear'
        And 7 of them are 'problem' messages
        Then 7 'problem' messages are sent immediately
        And 'clear' messages are aggregated into one message

