
# /*
#   Index
# */
# Author: PerterPon<PerterPon@gmail.com>
# Create: Sat Feb 07 2015 16:26:39 GMT+0800 (CST)
#

"use strict"

methods      = require 'methods'
pathToRegexp = require './path-to-regexp'
urlLib       = require 'url'

matchMethod  = ( req, requiredMethod ) ->
  { method } = req
  return true unless requiredMethod?
  return true if method is requiredMethod
  return true if 'HEAD' is requiredMethod and 'GET' is method
  return false

matchPath = ( req, re, reqParams ) ->

  { url, method } = req

  { pathname } = urlLib.parse url

  if m   = re.exec pathname
    args = m.slice( 1 ).map ( val ) -> decodeURIComponent val if val?
    req.originatorParam = args
    if null isnt reqParams
      params     = {}
      for name, idx in reqParams
        params[ name ] = args[ idx ]
      req.params = params
    true
  else
    false

create    = ( method ) ->
  method  = method.toUpperCase() if method?

  ( path, fn, opt ) ->
    # trans path to regexp.
    re    = pathToRegexp path, opt

    reqParams = path.match /\:\w+\/?/g

    # erase the '/:' or ':' prefix, and '/' sufix
    if null isnt reqParams
      reqParams = reqParams.map ( val ) ->
        ff    = 0
        bb    = val.length
        if 0 is val.indexOf '\/\:'
          ff  = 2
        else if 0 is val.indexOf '\:'
          ff  = 1
        if val.length - 1 is val.lastIndexOf '\/'
          bb -= 1
        val.substring ff, bb

    if 'GeneratorFunction' is fn.constructor.name
      return ( args..., next ) ->
        # koa support
        { req } = @ or {}
        req ?= args[ 0 ]

        # match method
        return yield next unless matchMethod req, method

        args.push next

        # match path
        if true is matchPath req, re, reqParams
          yield fn.apply @, args
          return

        # miss, to next
        yield next

    else
      return ( req, res, next ) ->
        # match method
        return next() unless matchMethod req, method

        # match path
        if true is matchPath req, re, reqParams
          fn req, res, next
          return

        # miss, to next
        next()

methods.forEach ( method ) ->
  exports[ method ] = create method

exports.all = create()