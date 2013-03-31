Survey = require '../models/survey'

# Survey model's CRUD controller.
class SurveyController 

  # Lists all surveys
  index: (req, res) ->
    Survey.find {}, (err, surveys) ->
      switch req.format
        when 'json' then res.json surveyss
        else res.render 'surveys/index', {surveys: surveys}

  new: (req, res) ->
    res.render 'surveys/new', {survey: new Survey, errs: null}

  edit: (req, res) ->
    Survey.findById req.params.survey, (err, survey) ->
      if err
        survey = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json survey
        else res.render 'surveys/edit', {survey: survey, errs: null}

  # Creates new survey with data from `req.body.survey`
  create: (req, res) ->
    for key, value of req.body
      console.log key + ": " + value
    if typeof req.body.userId is 'undefined' or req.body.userId is null
      console.log req.body.userId
      survey = new Survey req.body.survey
      survey.save (err, survey) ->
        if not err
          res.send survey
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500
    else
      console.log 'create surveys'
      for survey in req.body.surveyResults
        console.log survey
        survey.userId = req.body.userId
      Survey.collection.insert req.body.surveyResults, (err, surveys) ->
        if not err
          res.send {surveys: surveys}
          res.statusCode = 201
        else
          res.send err
          res.statusCode = 500
        
  # Gets survey by id
  show: (req, res) ->
    Survey.findById req.params.survey, (err, survey) ->
      if err
        survey = err
        res.statusCode = 500
      switch req.format
        when 'json' then res.json survey
        else res.render 'surveys/show', {survey: survey}

  # Updates survey with data from `req.body.survey`
  update: (req, res) ->
    Survey.findByIdAndUpdate req.params.survey, {"$set":req.body.survey}, (err, survey) ->
      if not err
        res.send survey
      else
        res.send err
        res.statusCode = 500
    
  # Deletes survey by id
  destroy: (req, res) ->
    Survey.findByIdAndRemove req.params.survey, (err) ->
      if not err
        res.send {}
      else
        res.send err
        res.statusCode = 500

module.exports = new SurveyController