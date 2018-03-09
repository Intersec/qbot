'use strict'

util = require('util')

class NotifHandler
  constructor: (@notifier) ->

  error: (err, body) ->
    console.log "#{@notifier} error: #{err.message}. Data: #{util.inspect(body)}"
    console.log err.stack

  dataMethodJSONParse: (req, data) ->
    return false if typeof req.body != 'object'
    ret = Object.keys(req.body).filter (val) ->
      val != '__proto__'

    try
      if ret.length == 1
        return JSON.parse ret[0]
    catch err
      return false

    return false

  dataMethodRaw: (req) ->
    return false if typeof req.body != 'object'
    return req.body

  dataFetch: (req, robot) ->
    data = null

    filterChecker = (item, callback) ->
      return if data

      ret = item(req)
      if (ret)
        data = ret
        return true

    [@dataMethodJSONParse, @dataMethodRaw].forEach(filterChecker)

    robot.logger.debug "received push: #{util.inspect(data, {depth: null})}"

    return data

module.exports = { NotifHandler }
