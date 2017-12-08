'use strict'

# For the moment, only push msgs in a test channel

get_user_subs_key = (nickname) -> "#{nickname}.subscriptions"


is_prod_ready = ->
  env = process.env.QBOT_PROD_READY
  return env? and env == '1'


fix_channel = (channel, text) ->
  if is_prod_ready()
    return [channel, text]
  else
    return ['#qbot-dev', "notification to #{channel}: #{text}"]


module.exports = (robot) ->

  # Handle notifications
  robot.on 'user-send', (nickname, type, text, msg) ->
    # Check the user has signed up for this type of notifications
    subs = robot.brain.get(get_user_subs_key(nickname))
    if not subs? or type not in subs
      if not is_prod_ready()
        robot.messageRoom(
          '#qbot-dev',
          "unsubscribed #{type} notif for @#{nickname}"
        )

    # send msg to user
    [chan, text] = fix_channel "@#{nickname}", text
    robot.adapter.client.web.chat.postMessage(chan, text, msg)


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

