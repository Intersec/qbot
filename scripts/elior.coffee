# Description:
#   Interface with the elior restaurant API
#
# Commands:
#   qbot menu - Reply with the menu for the current day
#
# Author:
#   Youx

'use strict'

fixCase = (str) -> str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()

module.exports = (robot) ->
  robot.respond /menu/, (chat) ->
    robot.http("https://timechef.elior.com/api/restaurant/1271/menus")
      .get() (err, res, body) ->
        if err
          console.log "error: " + err
        else
          data = JSON.parse body
          plats = (data[0].famillePlats[0].plats.map (p) -> fixCase(p.libelle)).join ', '
          day = data[0].date.replace 'T00:00:00Z', ''
          chat.reply "Menu du #{day} : #{plats}"
