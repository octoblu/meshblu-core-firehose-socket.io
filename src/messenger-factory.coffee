_ = require 'lodash'
redis   = require 'ioredis'
RedisNS = require '@octoblu/redis-ns'

class MessengerFactory
  constructor: ({@uuidAliasResolver, @namespace, @redisUri}) ->

  build: =>
    client = _.bindAll new RedisNS @namespace, redis.createClient(@redisUri)
    # new MessengerManager {client, @uuidAliasResolver}

module.exports = MessengerFactory
