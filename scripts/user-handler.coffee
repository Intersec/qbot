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


  # Redmine status
  robot.respond /redmine$/, (res) ->
    nickname = res.envelope.user.name
    subs = robot.brain.get(get_user_subs_key(nickname))
    if 'redmine' in subs
      msg  = "You are already subscribed to redmine notifications. "
      msg += "What more could you want :upside_down_face:?\n"
      msg += "To unsubscribe, use the `redmine unsubscribe` command"
    else
      msg  = "You are not subscribed to redmine notifications. "
      msg += "You're missing out! :sunglasses:\n"
      msg += "To subscribe, use the `redmine subscribe` command"

    res.send msg

  # Redmine sub/unsub
  robot.respond /redmine (.*)/i, (res) ->
      cmd = res.match[1]

      nickname = res.envelope.user.name
      key = get_user_subs_key(nickname)
      subs = robot.brain.get(key)
      if not subs?
        subs = []

      type = 'redmine'

      if cmd == 'unsubscribe'
        index = subs.indexOf(type)
        if index == -1
          res.send "You are not subscribed to #{type} notifications."
          return
        subs.splice(index, 1)
        res.send "You are no longer subscribed to #{type} notifications."
      else if cmd == 'subscribe'
        if type in subs
          res.send "You are already subscribed to #{type} notifications."
          return
        subs.push type
        res.send "You will now receive #{type} notifications."
      else
        res.send "Unknown #{cmd} command."
        return

      robot.brain.set(key, subs)

