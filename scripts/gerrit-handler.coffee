# Handle Gerrit webhook notifications

'use strict'

exec = require('child_process').exec
notifier = require('./notif-handler.coffee')

class GerritNotifier extends notifier.NotifHandler
  constructor: ->
    super("gerrit-notify")

  @getUserLogin: (user, finished) ->
    split = user.split(/\<|\>/)
    if split.length < 2
      split = user.split(/\(|\)/)
    mail = split[1]
    exec 'ldapsearch -x -b dc=intersec,dc=com \'mail='+mail+'\' | grep \'uid:\' | sed \'s/uid: //\'', (err, stdout, stderr) ->
      if err
        robot.logger.debug err
      finished stdout.trim()

  process: (req, res, robot) ->
    res.end('')
    data = @dataFetch(req, robot)

    GerritNotifier.getUserLogin(data.change_owner, ((login) ->
      data.nickname = login
      GerritNotifier.getUserLogin(data.author, ((login) ->
        data.emitter = login
        robot.emit 'gerrit-notif', data
      ))
    ))

module.exports = (robot) ->
  robot.gerrit_notifier = new GerritNotifier
  robot.router.post "/hubot/gerrit-notify", (req, res) ->
    details = robot.gerrit_notifier.process req, res, robot
