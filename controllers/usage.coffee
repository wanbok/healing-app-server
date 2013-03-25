Usage = require '../models/usage'

# Usage model's CRUD controller.
class UsageController 

  # Lists all usages
  index: (req, res) ->
    Usage.find {}, (err, usages) ->
      switch req.format
        when 'json' then res.json usages
        else res.render 'usages/index', {usages: usages}

  new: (req, res) ->
    res.render 'usages/new', {usage: new Usage, errs: null}

  edit: (req, res) ->
    Usage.findById req.params.usage, (err, usage) ->
      if err
        usage = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json usage
        else res.render 'usages/edit', {usage: usage, errs: null}

  # Creates new usage with data from `req.body.usage`
  create: (req, res) ->
    if typeof req.body.userId is 'undefined' or req.body.userId is null
      usage = new Usage req.body.usage
      usage.save (err, usage) ->
        if not err
          res.send usage
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500  
    else
      for usage in req.body.usages
        usage.userId = req.body.userId
      Usage.collection.insert req.body.usages, (err, usages) ->
        if not err
          res.send usages
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500  
    
        
  # Gets usage by id
  show: (req, res) ->
    Usage.findById req.params.usage, (err, usage) ->
      if err
        usage = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json usage
        else res.render 'usages/show', {usage: usage}

  # Updates usage with data from `req.body.usage`
  update: (req, res) ->
    Usage.findByIdAndUpdate req.params.usage, {"$set":req.body.usage}, (err, usage) ->
      if not err
        res.send usage
      else
        res.send err
        res.statusCode = 500
    
  # Deletes usage by id
  destroy: (req, res) ->
    Usage.findByIdAndRemove req.params.usage, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new UsageController