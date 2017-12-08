'use strict'

module.exports = (robot) ->
  # Handle redmine notifications
  robot.on 'redmine-notif', (details) ->
    # Build a pretty message for the related ticket
    msg = {
      attachments: [
        {
          title: "Ticket ##{details.issueId}: #{details.subject}"
          title_link: details.url
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
          color: "#6878cc"
        }
      ]
      as_user: true
    }
    text = "#{details.updater.firstname} #{details.updater.lastname} has " +
           "#{details.action} ##{details.issueId}"

    # Send notification to assignee
    if details.assignee != ""
      robot.emit 'user-send', details.assignee, 'redmine', text, msg
