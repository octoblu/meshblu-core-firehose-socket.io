_           = require 'lodash'
async       = require 'async'
URL         = require 'url'

class SocketIOHandler
  constructor: ({@socket,@meshbluConfig,@hydrantManagerFactory}) ->

  initialize: =>
    {pathname} = URL.parse @socket.client.request.url
    # has a trailing slash
    uuid = _.first _.takeRight pathname.split(/\//), 2

    @firehose = @hydrantManagerFactory.build()
    @firehose.on 'message', (message) =>
      @socket.emit 'message', message

    @firehose.connect {uuid}, (error) =>
      throw error if error?

  onDisconnect: =>
    @firehose?.close()

module.exports = SocketIOHandler
