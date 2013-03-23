App = require '../models/app'
Category = require '../models/category'

# App model's CRUD controller.
class AppController 

  # Lists all apps
  index: (req, res) ->
    App.find {}, (err, apps) ->
      switch req.format
        when 'json' then res.json apps
        else res.render 'apps/index', {apps: apps}

  new: (req, res) ->
    Category.find {}, (err, categories) ->
      res.render 'apps/new', {app: new App, errs: null, categories: categories}

  edit: (req, res) ->
    App.findById req.params.app, (err, app) ->
      if err
        app = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json app
        else res.render 'apps/edit', {app: app, errs: null, categories: Category.find()}

  # Creates new app with data from `req.body.app`
  create: (req, res) ->
    app = new App req.body.app
    app.save (err, app) ->
      if not err
        res.send app
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets app by id
  show: (req, res) ->
    App.findById req.params.app, (err, app) ->
      if err
        app = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json app
        else res.render 'apps/show', {app: app}

  # Updates app with data from `req.body.app`
  update: (req, res) ->
    App.findByIdAndUpdate req.params.app, {"$set":req.body.app}, (err, app) ->
      if not err
        res.send app
      else
        res.send err
        res.statusCode = 500
    
  # Deletes app by id
  destroy: (req, res) ->
    App.findByIdAndRemove req.params.app, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new AppController