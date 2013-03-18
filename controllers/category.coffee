Category = require '../models/category'

# Category model's CRUD controller.
class CategoryController 

  # Lists all categories
  index: (req, res) ->
    Category.find {}, (err, categories) ->
      switch req.format
        when 'json' then res.json categories
        else res.render 'categories/index', {categories: categories}

  new: (req, res) ->
    res.render 'categories/new', {category: new Category, errs: null}

  edit: (req, res) ->
    Category.findById req.params.category, (err, category) ->
      if err
        category = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json category
        else res.render 'categories/edit', {category: category, errs: null}

  # Creates new category with data from `req.body.category`
  create: (req, res) ->
    category = new Category req.body.category
    category.save (err, category) ->
      if not err
        res.send category
        res.statusCode = 201
      else
        res.send err
        res.statusCode = 500
        
  # Gets category by id
  show: (req, res) ->
    Category.findById req.params.category, (err, category) ->
      if err
        category = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json category
        else res.render 'categories/show', {category: category}

  # Updates category with data from `req.body.category`
  update: (req, res) ->
    Category.findByIdAndUpdate req.params.category, {"$set":req.body.category}, (err, category) ->
      if not err
        res.send category
      else
        res.send err
        res.statusCode = 500
    
  # Deletes category by id
  destroy: (req, res) ->
    Category.findByIdAndRemove req.params.category, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new CategoryController