'use strict'

module.exports = (robot) ->
  getMenu = (chat, day) ->
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
            chat.reply (data.map (dayMenu) -> formatMenu dayMenu).join '\n'
          else if day < 5
            chat.reply formatMenu data[day]

  robot.respond /menu$/, (chat) ->
    getMenu chat, 0
  robot.respond /menu du jour$/, (chat) ->
    getMenu chat, 0
  robot.respond /menu de demain$/, (chat) ->
    getMenu chat, 1
  robot.respond /menu de la semaine$/, (chat) ->
    getMenu chat, -1
