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

url = require('url')
querystring = require('querystring')
util = require('util')

class RedmineNotifier
  error: (err, body) ->
    console.log "redmine-notify error: #{err.message}. Data: #{util.inspect(body)}"
    console.log err.stack

  dataMethodJSONParse: (req, data) ->
    return false if typeof req.body != 'object'
    ret = Object.keys(req.body).filter (val) ->
      val != '__proto__'

    try
      if ret.length == 1
        return JSON.parse ret[0]
    catch err
      return false

    return false

  dataMethodRaw: (req) ->
    return false if typeof req.body != 'object'
    return req.body

  process: (req, res, robot) ->
    query = querystring.parse(url.parse(req.url).query)

    res.end('')

    envelope = {}
    envelope.user = {}

    data = null

    filterChecker = (item, callback) ->
      return if data

      ret = item(req)
      if (ret)
        data = ret
        return true

    [@dataMethodJSONParse, @dataMethodRaw].forEach(filterChecker)

    robot.logger.debug "received push: #{util.inspect(data, {depth: null})}"

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
        }
      else return undefined

module.exports = (robot) ->
  robot.redmine_notifier = new RedmineNotifier
  robot.router.post "/hubot/redmine-notify", (req, res) ->
    details = robot.redmine_notifier.process req, res, robot
    robot.emit details.type, details
