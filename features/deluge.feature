Feature: Limit number of messages being sent out within specific time period
  As a frequent alerts receipient, I don't want to receive too many messages when something is down. Instead
  I would like to be alerted only once per hour or other configurable period.

  Scenario: no messages have been sent before
    Given server sends 1 notification
    When there was no notifications sent within last hour
    Then notification is sent

  Scenario: some messages were sent, but it was less then threshold
    Given server sends notification
    When system released less than MAX messages during TIME_THRESHOLD
    Then notification is sent

  Scenario: threshold has been exceeded
    Given server sends notification
    When number of messages sent within notification period is larger than allowed
    Then message is ignored

  Scenario: multiple messages spread over time
    Given server sends two messages
    When time between two messages is larger than threshold
    Then both messages are sent

