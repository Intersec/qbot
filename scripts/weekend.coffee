# Description:
#   Indicate whether it is soon the week-end or not
#
# Commands:
#   qbot weekend - Reply with the content of the https://estcequecestbientotleweekend.fr/ website
#
# Author:
#   alineIntersec

'use strict'

module.exports = (robot) ->
  robot.respond /weekend/, (chat) ->
    robot.http("https://estcequecestbientotleweekend.fr")
      .get() (err, res, body) ->
        if err
          console.log "Encountered an error :( #{err}"
          return
        pattern = /<p class="msg">\s*(.*)\s*<\/p>/
        text = body.match(pattern)[1]
        chat.reply text


