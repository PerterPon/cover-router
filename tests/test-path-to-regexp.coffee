
# /*
#   Unit test for PathToRegExp
# */
# Author: yuhan.wyh<yuhan.wyh@alibaba-inc.com>
# Create: Tue Feb 10 2015 16:10:26 GMT+0800 (CST)
#

"use strict"

expect = require 'expect.js'

PathToRegExp  = require '../lib/path-to-regexp'

describe 'path to regext', ->

  it 'pattern /test, request /test', ( done ) ->
    re    = PathToRegExp '/test'
    [ _ ] = re.exec '/test'
    expect( _ ).to.be '/test'
    done()

  it 'pattern /test, request /test/test1', ( done ) ->
    re    = PathToRegExp '/test'
    [ _ ] = re.exec '/test/test1'
    expect( _ ).to.be '/test/test1'
    done()

  it 'pattern /test/:test1, request /test/test1', ( done ) ->
    re    = PathToRegExp '/test/:test1'
    [ _, test1 ] = re.exec '/test/test1'
    expect( _ ).to.be '/test/test1'
    expect( test1 ).to.be 'test1'
    done()

  it 'pattern /:test/test1/:test2, request /test/test1/test2', ( done ) ->
    re    = PathToRegExp '/:test/test1/:test2'
    [ _, test, test2 ] = re.exec '/test/test1/test2'
    expect( _ ).to.be '/test/test1/test2'
    expect( test ).to.be 'test'
    expect( test2 ).to.be 'test2'
    done()

  it 'pattern /^\/test\/.*$/, request /test/test1', ( done ) ->
    re    = PathToRegExp /^\/test\/.*$/
    [ _ ] = re.exec '/test/test1'
    expect( _ ).to.be '/test/test1'
    done()

  it 'pattern /test/:test1, request /test1/test1', ( done ) ->
    re    = PathToRegExp '/test/:test1'
    res   = re.exec '/test1/test1'
    expect( res ).to.be null
    done()

  it 'pattern /test, request /test1', ( done ) ->
    re    = PathToRegExp '/test'
    expect( re.exec '/test1' ).to.be null
    done()
