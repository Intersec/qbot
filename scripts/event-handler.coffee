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

    # Use description of the ticket if just opened,
    # update notes if updated
    if details.action == 'opened'
      content = details.description
    else
      content = details.notes

    # Build a pretty message for the related ticket
    msg = {
      attachments: [
        {
          title: "#{details.tracker} ##{details.issueId}: #{details.subject}"
          title_link: details.url
          text: content
          fallback: ""
          fields: [
            {
               title: "Status"
               value: details.status
               short: true
            },
            {
               title: "Priority"
               value: details.priority
               short: true
            },
            {
               title: "Project"
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
      msg.attachments[0].fields.unshift({
        title: "Assignee"
        value: "#{details.assignee.firstname} #{details.assignee.lastname}"
        short: true
      })

    text = "#{details.updater.firstname} #{details.updater.lastname} has " +
           "updated ##{details.issueId}"

    notified = {}
    # notify user if not updater and not already notified
    notify_user = (login) ->
      if login != details.updater.login and login not of notified
        robot.emit 'user-send', login, 'redmine', text, msg
        notified[login] = true

    # Send notification to assignee
    if details.assignee
      notify_user details.assignee.login

    # Send notification to author
    notify_user details.author.login

    # Send notification to watchers
    for idx,w of details.watchers
      notify_user w.login
