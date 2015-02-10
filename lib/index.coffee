
# /*
#   Index
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Sat Feb 07 2015 16:26:39 GMT+0800 (CST)
#

"use strict"

methods      = require 'methods'
debug        = require( 'debug' )( 'hc-cover-router' )
pathToRegexp = require './path-to-regexp'

matchMethod  = ( req, requiredMethod ) ->
  { method } = req
  return true unless requiredMethod?
  return true if method is requiredMethod
  return true if 'HEAD' is requiredMethod and 'GET' is method
  return false

matchPath = ( req, re, reqParams ) ->

  { url, method } = req

  if m    = re.exec url
    console.log re, url
    args  = m.slice( 1 ).map ( val ) -> decodeURIComponent val if val?
    debug '%s %s matches %j', method, url, args

    console.log reqParams

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
    re = pathToRegexp path, opt

    console.log re

    reqParams = path.match /\:\w+\/?/g
    if null isnt reqParams
      reqParams = reqParams.map ( val ) ->
        ff    = 0
        bb    = val.length
        if 0 is val.indexOf '\/\:'
          ff  = 2
        else if 0 is val.indexOf '\:'
          ff  = 1
        if 0 is val.lastIndexOf '\\'
          bb -= 1
        val.substring ff, bb

    if 'GeneratorFunction' is fn.constructor.name
      return ( req, res, next ) ->
        # match method
        yield next unless matchMethod req, method
        # match path

        if true is matchPath req, re, reqParams
          yield fn req, res, next
          return

        # miss, to next
        yield next

    else
      return ( req, res, next ) ->
        # match method
        next() unless matchMethod req, method

        # match path
        if true is matchPath req, re, reqParams
          fn req, res, next
          return

        # miss, to next
        next()

methods.forEach ( method ) ->
  exports[ method ] = create method

exports.all = create()
