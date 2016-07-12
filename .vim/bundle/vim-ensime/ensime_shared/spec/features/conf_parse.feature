Feature: Load Config File
  In order to run Ensime
  We need to load a config file

  Scenario: Parse Config Name
    Given The config resources/test.conf
    When We load the config
    Then We extract the name testing

  Scenario: Parse Scala Version
    Given The config resources/test.conf
    When We load the config
    Then We extract the scala version 2.11.8

  Scenario: Parse Nested Module SExp
    Given The config resources/test.conf
    When We load the config
    Then We can parse nested expressions

  Scenario: Fails to load invalid conf
    Given The config resources/broken.conf
    When We load the config
    Then We receive a failure

  Scenario: Fails to load a missing conf
    Given The config resources/nope.conf
    When We load the config
    Then We receive a failure
