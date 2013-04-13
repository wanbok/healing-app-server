Install = require '../models/install'

# Install model's CRUD controller.
class InstallController 

  # Lists all installs
  index: (req, res) ->
    Install.find {}, (err, installs) ->
      switch req.format
        when 'json' then res.json installs
        else res.render 'installs/index', {installs: installs}

  new: (req, res) ->
    res.render 'installs/new', {install: new Install, errs: null}

  edit: (req, res) ->
    Install.findById req.params.install, (err, install) ->
      if err
        res.statusCode = 500
        install = err
      switch req.format
        when 'json' then res.json install
        else res.render 'installs/edit', {install: install, errs: null}

  # Creates new install with data from `req.body.install`
  create: (req, res) ->
    if typeof req.body.installs isnt 'undefined' and Object.prototype.toString.call(req.body.installs) is '[object Array]'
      addingUserToInstalls(req.params.user, req.body.installs)
      Install.collection.insert req.body.installs, (err, installs) ->
        if not err
          res.statusCode = 201
          res.send {installs: installs}
        else
          res.statusCode = 500
          res.send err
    else
      req.body.install.userId = req.params.user
      install = new Install req.body.install
      install.save (err, install) ->
        if not err
          res.send install
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500
        
  # Gets install by id
  show: (req, res) ->
    Install.findOne {userId: req.params.user, appPkg: req.params.install}, (err, install) ->
      if err
        install = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json install
        else res.render 'installs/show', {install: install}

  # Updates install with data from `req.body.install`
  update: (req, res) ->
    req.params.install += "." + req.format if req.format isnt 'json' and typeof req.format isnt 'undefined'
    console.log 'Actions is ' + req.body.action
    if req.body.action is 'add'
      Install.findOneAndUpdate {userId: req.params.user, appPkg: req.params.install}, {"$pushAll": {forbiddens:req.body.install.forbiddens}}, (err, install) ->
        if not err
          console.log 'Succeed updating install'
          console.log install
          res.statusCode = 200
          res.json install
        else
          console.log 'Failed updating install'
          res.statusCode = 500
          res.json err
    else if req.body.action is 'remove'
      startTimes = if typeof req.body.install.forbiddenStartTimes isnt 'undefined'
      then req.body.install.forbiddenStartTimes
      else req.body.install.forbiddens.map(mapForForbiddenStartTime)
      console.log "startTimes: "+startTimes
      Install.findOneAndUpdate {userId: req.params.user, appPkg: req.params.install}, {"$pull": {forbiddens:{startTime:{"$in":startTimes}}}}, (err, install) ->
        if not err
          console.log 'Succeed updating install'
          console.log install
          res.statusCode = 200
          res.json install
        else
          console.log 'Failed updating install'
          res.statusCode = 500
          res.json err
    else
      Install.findOneAndUpdate {userId: req.params.user, appPkg: req.params.install}, {"$set": req.body.install}, {upsert: true}, (err, install) ->
        if not err
          console.log 'Succeed updating install'
          console.log install
          res.statusCode = 200
          res.json install
        else
          console.log 'Failed updating install'
          res.statusCode = 500
          res.json err
    
  # Deletes install by id
  destroy: (req, res) ->
    req.params.install += "." + req.format if req.format isnt 'json' and typeof req.format isnt 'undefined'
    Install.findOneAndRemove {userId: req.params.user, appPkg: req.params.install} ,(err) ->
      if not err
        res.statusCode = 200
        res.send {}
      else
        res.statusCode = 500
        res.send err

module.exports = new InstallController

addingUserToInstalls = (user, installs) ->
  for install in installs
    install.userId = user

mapForForbiddenStartTime = (forbidden) ->
  return forbidden.startTime
