'use strict'

module.exports = (robot) ->
  robot.on 'opened', (details) ->
    robot.messageRoom '@' + details.assignee, """ new ticket: #{details.issueId} """
