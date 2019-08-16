# Description:
#   Interface with the elior restaurant API
#
# Commands:
#   qbot menu - Reply with the menu for the current day
#
# Author:
#   Youx

'use strict'
HubotCron = require 'hubot-cronjob'

module.exports = (robot) ->
  getMenu = (day, cb) ->
    formatMenu = (dayMenu) ->
      formatDay = () -> dayMenu.date.replace 'T00:00:00Z', ''

      formatPlats = () ->
        fixCase = (str) -> str.charAt(0).toUpperCase() + str.slice(1).toLowerCase()
        (dayMenu.famillePlats[0].plats.map (p) -> fixCase(p.libelle)).join ', '

      "Menu du #{formatDay dayMenu} : #{formatPlats dayMenu}"

    robot.http("https://timechef.elior.com/api/restaurant/1271/menus")
      .get() (err, res, body) ->
        if err
          console.log "error: " + err
        else
          data = JSON.parse body
          if day < 0
            cb (data.map (dayMenu) -> formatMenu dayMenu).join '\n'
          else if day < 5
            cb formatMenu data[day]

  robot.respond /menu$/, (chat) ->
    getMenu 0, (msg) -> chat.reply msg
  robot.respond /menu du jour$/, (chat) ->
    getMenu 0, (msg) -> chat.reply msg
  robot.respond /menu de demain$/, (chat) ->
    getMenu 1, (msg) -> chat.reply msg
  robot.respond /menu de la semaine$/, (chat) ->
    getMenu -1, (msg) -> chat.reply msg

  # each work day @ 11:50, the day's menu
  new HubotCron '50 11 * * 1-5', 'Europe/Paris', () ->
    getMenu 0, (msg) -> robot.messageRoom 'qbot-dev', msg
  # each monday @ 10, the week's menu
  new HubotCron '0 10 * * 1', 'Europe/Paris', () ->
    getMenu -1, (msg) -> robot.messageRoom 'qbot-dev', msg
