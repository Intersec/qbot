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

  process: (req, res) ->
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
    console.log "received push: #{util.inspect(data, { depth: null })}"

    payload = data.payload
    action = payload.action
    issue = payload.issue
    assignee = unless issue.assignee? then "" else issue.assignee.login
    issueId = issue.id

    #project = issue.project.name
    #author = issue.author.login
    #tracker = issue.tracker.name
    #issueSubject = issue.subject
    #status = issue.status.name
    #priority = issue.priority.name
    #issueUrl = payload.url
    #message = """
    #          [#{project}] #{author} #{action} #{tracker}##{issueId}
    #          Subject: #{issueSubject}
    #          Status: #{status}
    #          Priority: #{priority}
    #          Assignee: #{assignee}
    #          URL: #{issueUrl}
    #          """

    switch action
      when 'opened'
        return {
          type: action,
          assignee: assignee,
          issueId: issueId
        }
      when 'updated'
        return {
          type: action,
          assignee: assignee,
          issueId: issueId
        }
      else return undefined

module.exports = (robot) ->
  robot.redmine_notifier = new RedmineNotifier

  robot.router.post "/hubot/redmine-notify", (req, res) ->
    details = robot.redmine_notifier.process req, res
    robot.emit details.type, details
