'use strict'

# For the moment, only push msgs in a test channel

get_user_subs_key = (nickname) -> "#{nickname}.subscriptions"

module.exports = (robot) ->

  # Handle notifications
  robot.on 'user-send', (nickname, type, text, msg) ->
    # Check the user has signed up for this type of notifications
    subs = robot.brain.get(get_user_subs_key(nickname))
    if not subs? or type not in subs
      robot.messageRoom(
        '#qbot-dev',
        "unsubscribed notif of type `#{type}` sent to @#{nickname}"
      )

    # send msg to user
    robot.adapter.client.web.chat.postMessage(
      '#qbot-dev',
      "notif of type #{type} to @#{nickname}: #{text}",
      msg
    )


  # List subscriptions for the user
  robot.respond /subscriptions get/i, (res) ->
    nickname = res.envelope.user.name
    subs = robot.brain.get(get_user_subs_key(nickname))
    if subs?
      subs_joined = subs.join(', ')
      res.send "you are subscribed to notifications of type #{subs_joined}"
    else
      res.send "you are not subscribed to any notifications"


  # Subscribe to a notification
  robot.respond /subscribe (.*)/i, (res) ->
      type = res.match[1]

      # TODO: generalize this list
      if type != 'redmine'
        res.send "unknown notification type `#{type}`"
        return

      nickname = res.envelope.user.name
      key = get_users_subs_key(nickname)
      subs = robot.brain.get(key)
      if subs?
        if type in subs
          res.send "you are already subscribed to #{type} notifications"
          return
        subs.push type
      else
        subs = [type]

      robot.brain.set(key, subs)
      res.send "you will now receive #{type} notifications"

