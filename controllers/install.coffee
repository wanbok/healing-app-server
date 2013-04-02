Install = require '../models/install'

# Install model's CRUD controller.
class InstallController 

  # Lists all installs
  index: (req, res) ->
    Install.find {}, (err, installs) ->
      switch req.format
        when 'json' then res.json installss
        else res.render 'installs/index', {installs: installs}

  new: (req, res) ->
    res.render 'installs/new', {install: new Install, errs: null}

  edit: (req, res) ->
    Install.findById req.params.install, (err, install) ->
      if err
        install = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json install
        else res.render 'installs/edit', {install: install, errs: null}

  # Creates new install with data from `req.body.install`
  create: (req, res) ->
    if typeof req.body.installs is not 'undefined' and Object.prototype.toString.call(req.body.installs) is '[object Array]'
      Install.collection.insert req.body.installs, (err, installs) ->
        if not err
          res.send {installs: installs}
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500
    else
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
    Install.findById req.params.install, (err, install) ->
      if err
        install = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json install
        else res.render 'installs/show', {install: install}

  # Updates install with data from `req.body.install`
  update: (req, res) ->
    Install.findOneAndUpdate {userId: req.params.install}, {"$set": req.body.install}, {upsert: true}, (err, install) ->
      if not err
        console.log 'Succeed updating install'
        console.log install
        res.send install
        res.statusCode = 200
      else
        console.log 'Failed updating install'
        res.send err
        res.statusCode = 500
    
  # Deletes install by id
  destroy: (req, res) ->
    Install.findByIdAndRemove req.params.install, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new InstallController