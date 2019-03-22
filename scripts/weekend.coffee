# Description:
#   Indicate wheither it is soon the week-end or not
#
# Commands:
#   qbot weekend - Reply with the content of the https://estcequecestbientotleweekend.fr/ webiste
#
# Author:
#   alineIntersec

'use strict'

fixCase = (str) -> str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()

module.exports = (robot) ->
  robot.respond /weekend/, (chat) ->
    robot.http("https://estcequecestbientotleweekend.fr")
      .get() (err, res, body) ->
        if err
          console.log "Encountered an error :( #{err}"
          return
        else
            pattern = \<p class="msg">(.*)<\/p>\
            text = body.match(pattern)[1]
            chat.reply text


