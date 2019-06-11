# Handle Redmine webhook notifications
#
# Initially copied from https://github.com/tenten0213/hubot-redmine-notifier
#
# Dependencies:
#   "url": ""
#   "querystring": ""
#
# Configuration:
#   Install [Redmine Webhook Plugin](https://github.com/suer/redmine_webhook) to your Redmine.
#   Add hubot's endpoint to Redmine Project - Settings - WebHook - URL `http://<hubot-host>:<hubot-port>/hubot/redmine-notify
#
# URLS:
#   POST /hubot/redmine-notify

'use strict'

notifier = require('./notif-handler.coffee')

class RedmineNotifier extends notifier.NotifHandler
  constructor: ->
    super("redmine-notify")

  process: (req, res, robot) ->
    res.end('')
    data = @dataFetch(req, robot)

    payload = data.payload
    issue = payload.issue
    if payload.journal?
      updater = payload.journal.author
    else
      updater = issue.author

    switch payload.action
      when 'opened', 'updated'
        return {
          type: 'redmine-notif'
          action: payload.action
          assignee: issue.assignee
          author: issue.author
          updater: updater
          issueId: issue.id
          subject: issue.subject
          description: issue.description
          status: issue.status.name
          tracker: issue.tracker.name
          priority: issue.priority.name
          project: issue.project.name
          url: payload.url
          watchers: issue.watchers
          notes: if payload.journal? then payload.journal.notes else undefined
          journal_html: payload.journal_html
        }
      else return undefined

module.exports = (robot) ->
  robot.redmine_notifier = new RedmineNotifier
  robot.router.post "/hubot/redmine-notify", (req, res) ->
    details = robot.redmine_notifier.process req, res, robot
    robot.emit details.type, details
