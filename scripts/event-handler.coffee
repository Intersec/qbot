'use strict'

util = require('util')

get_color_from_tracker = (tracker) ->
  switch tracker
    when 'Bug' then 'danger'
    when 'Feature', 'Main' then 'good'
    else '#6878cc'

module.exports = (robot) ->
  # Handle redmine notifications
  robot.on 'redmine-notif', (details) ->
    # Build a pretty message for the related ticket
    msg = {
      attachments: [
        {
          title: "Ticket ##{details.issueId}: #{details.subject}"
          title_link: details.url
          text: details.notes || details.description
          fallback: ""
          fields: [
            {
               title: "Status",
               value: details.status
               short: true
            },
            {
               title: "Tracker",
               value: details.tracker
               short: true
            },
            {
               title: "Priority",
               value: details.priority
               short: true
            },
            {
               title: "Project",
               value: details.project
               short: true
            }
          ]
          color: get_color_from_tracker details.tracker
        }
      ]
      as_user: true
    }

    if details.assignee
      msg.attachments[0].fields.push({
        title: "Assignee"
        value: "#{details.assignee.firstname} #{details.assignee.lastname}"
        short: true
      })

    text = "#{details.updater.firstname} #{details.updater.lastname} has " +
           "updated ##{details.issueId}"

    # hash of notified users, to avoid notifying the same person twice
    notified = {}

    # Send notification to assignee
    if details.assignee and details.updater.login != details.assignee.login
      robot.emit 'user-send', details.assignee.login, 'redmine', text, msg
      notified[details.assignee.login] = true

    # Send notification to author
    if details.author.login not of notified
      robot.emit 'user-send', details.author.login, 'redmine', text, msg
      notified[details.author.login] = true

    # Send notification to watchers
    for idx,w of details.watchers
      if w.login not of notified
        robot.emit 'user-send', w.login, 'redmine', text, msg
        notified[w.login] = true
