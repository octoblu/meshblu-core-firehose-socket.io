_   = require 'lodash'
URL = require 'url'

class SocketIOHandler
  constructor: ({ @socket, @meshbluConfig, @hydrant }) ->

  initialize: =>
    { pathname } = URL.parse @socket.client.request.url
    # has a trailing slash
    @uuid = _.first _.takeRight pathname.split(/\//), 2

    @hydrant.subscribe { @uuid }, =>
    @hydrant.on "message:#{@uuid}", @onMessage

  onMessage: (message) =>
    @socket.emit 'message', message

  onDisconnect: =>
    @hydrant.off "message:#{@uuid}", @onMessage
    @hydrant.unsubscribe { @uuid }, =>

module.exports = SocketIOHandler
