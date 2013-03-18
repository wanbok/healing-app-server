Friendship = require '../models/friendship'

# Friendship model's CRUD controller.
class FriendshipController 

  # Lists all friendships
  index: (req, res) ->
    Friendship.find {}, (err, friendships) ->
      switch req.format
        when 'json' then res.json friendships
        else res.render 'friendships/index', {friendships: friendships}

  new: (req, res) ->
    res.render 'friendships/new', {friendship: new Friendship, errs: null}

  edit: (req, res) ->
    Friendship.findById req.params.friendship, (err, friendship) ->
      if err
        friendship = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json friendship
        else res.render 'friendships/edit', {friendship: friendship, errs: null}

  # Creates new friendship with data from `req.body.friendship`
  create: (req, res) ->
    friendship = new Friendship req.body.friendship
    friendship.save (err, friendship) ->
      if not err
        res.send friendship
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets friendship by id
  show: (req, res) ->
    Friendship.findById req.params.friendship, (err, friendship) ->
      if err
        friendship = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json friendship
        else res.render 'friendships/show', {friendship: friendship}

  # Updates friendship with data from `req.body.friendship`
  update: (req, res) ->
    Friendship.findByIdAndUpdate req.params.friendship, {"$set":req.body.friendship}, (err, friendship) ->
      if not err
        res.send friendship
      else
        res.send err
        res.statusCode = 500
    
  # Deletes friendship by id
  destroy: (req, res) ->
    Friendship.findByIdAndRemove req.params.friendship, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new FriendshipController