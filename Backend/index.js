/*
Must need a running instance of MongoDB to get API running. Use the following commands:
	cd /usr/local/opt/mongodb/ 
	mongod

MongoDB now running on default port of 27017.
Also must call 'node index.js' on command line to start the Node server.

To update:
curl -H "Content-Type: application/json" -X PUT -d '{"title": "Good Golly Miss Molly"}' http://localhost:3000/items/{INSERT ID HERE}

To delete:
curl -H "Content-Type: application/json" -X DELETE http://localhost:3000/items/{INSERT ID HERE}




MongoDB terms in terms of RDBMS:
Database = Database
Collection = Table, exists within a database, no schema needed
Document = Row in table
Field - column

Example document structure in MongoDB:
{
   _id: ObjectId(7df78ad8902c)
   title: 'MongoDB Overview', 
   description: 'MongoDB is no sql database',
   by: 'tutorials point',
   url: 'http://www.tutorialspoint.com',
   tags: ['mongodb', 'database', 'NoSQL'],
   likes: 100, 
   comments: [	
      {
         user:'user1',
         message: 'My first comment',
         dateCreated: new Date(2011,1,20,2,15),
         like: 0 
      },
      {
         user:'user2',
         message: 'My second comments',
         dateCreated: new Date(2011,1,25,7,45),
         like: 5
      }
   ]
}
*/

// Import the HTTP libraries
var http = require('http'),
	express = require('express'),
	path = require('path'),
	bodyParser = require('body-parser')
	MongoClient = require('mongodb').MongoClient,
	Server = require('mongodb').Server,
	CollectionDriver = require('./CollectionDriver').CollectionDriver;

// Response/server variables
var responseCode = 200,
	port = 3000;

/*
This creates an Express app and sets its port to 3000 by default. 
You can overwrite this default by creating an environment variable named PORT. 
This type of customization is pretty handy during development tool, especially if you have multiple applications listening on various ports. 

In addition to app.get, Express supports app.post, app.put, app.delete among others.
*/
var app = express();
app.set("port", process.env.PORT || port);
app.set('views', path.join(__dirname, 'views'));	// specifies where the view templates live
app.set('view engine', 'jade');	// sets Jade as the view rendering engine
app.use(bodyParser.json()); // parse incoming body data, if it's JSON, then create a JSON object with it
app.use(bodyParser.urlencoded({
	extended: true
}));

var mongoHost = 'localHost'; // assumes MongoDB instance running locally on default port of  27017
var mongoPort = 27017; 
var collectionDriver;

var url = 'mongodb://' + mongoHost +':' + mongoPort +'/mongo-server';
MongoClient.connect(url, function(error, db) {	// Attempts to establish a connection to mongo server
	if (error) {
		console.log("Error! Exiting... Must start MongoDB first.");
		process.exit(1);	// Exits app if connection fails
	}

	console.log("Connected to MongoDB successfully.")
	collectionDriver = new CollectionDriver(db);	// create the collection driver, passing in the database
});

app.use(express.static(path.join(__dirname, 'public')));


// Helper Functions
function isJSON(jsonStr) {
	try { JSON.parse(jsonStr); }
	catch (e) { return false; }
	return true;
}

/*
Advanced Routing

static terms — /files only matches http://localhost:300/pages
parameters prefixed with “:” — /files/:filename matches /files/foo and /files/bar, but not /files
optional parameters suffixed with “?” — /files/:filename? matches both “/files/foo” and “/files”
regular expressions — /^\/people\/(\w+)/ matches /people/jill and /people/john

This route matching is useful when building REST APIs where you can specify dynamic paths to specific items in backend datastores.

Routing Example
Matches "localhost:3000/hi/every/body"

req.params.a = hi
req.params.b = every
req.params.c = body

app.get('/:a?/:b?/:c?', function (req,res) {
	res.send(req.params.a + ' ' + req.params.b + ' ' + req.params.c);
});
*/
app.get("/", function(req, res) {	// Routes the home page
	res.send('<html><body><h1>Hello World</h1></body></html>');
});

/*
Collection Routing using MongoDB.

A: "/collection" will match exactly that URL, but "/:collection" matches any first-level path store the requested name
B: Store the parameters
C: Use the collection specified in the parameter to find all values inside it.
D: If an error occurred, send a 400 error in the response
E: If the request accepts HTML result in the header, then go to line F.
F: Store the rendered HTML from data.jade (table form) to the response.

In the case that a two-level URL path given, it goes to line I.
I: Treats path as a collection name and an entity _id.
J: Request specific entity.
K: If entity found, return it as a JSON document.
*/
app.get("/:collection", function(req, res) {	// A ('read' of CRUD model)
	var params = req.params;	// B
	console.log("hasd");
	collectionDriver.readAll(req.params.collection, function(error, objs) {	// C
		if (error)	// D
			res.send(400, error);
		else {
			if (req.accepts('html')) // E
				res.render('data', {objects: objs, collection: req.params.collection});	// F
			else {
				res.send('Content-Type', 'application/json');	// G
				res.send(200, objs);	// H
			}
		}
	});
});

app.get("/add/users/:content", function(req, res) {
	var content = req.params.content;
	
	if (!isJSON(content)) {
		res.status(400).send({"error":"content was not in JSON format"});
		return;
	}
	
	res.send(200, "success");
});

app.post("/:collection", function(req, res) {	// new route for POST verb ('create' of CRUD model)
	var object = req.body;
	var collection = req.params.collection;
	collectionDriver.create(collection, object, function(error, docs) {
		if (error)
			res.send(400, error);
		else 
			res.status(201).send(docs);	// Returns success code 201 when resource is created
	});
});

app.get("/:collection/:entity", function(req, res) {	// I ('read' of CRUD model)
	var params = req.params;
	var entity = params.entity;
	var collection = params.collection;
	if (entity) {
		collectionDriver.read(collection, entity, function(error, objs) {	// J
			if (error)
				res.status(400).send(error);
			else {
				res.status(200).send(objs);	// K
			}
		});
	} else {
		res.status(400).send({error: 'bad url', url: req.url});
	}
});

app.put('/:collection/:entity', function(req, res) {	// 'update' of CRUD model
	var params = req.params;
	var collection = params.collection;
	var entity = params.entity;
	var obj = req.body;
	if (entity) {
		collectionDriver.update(collection, obj, entity, function(error, objs) {
			if (error)
				res.sendStatus(400, error);
			else
				res.sendStatus(200, objs);
		});
	} else {
		res.sendStatus(400, {"error" : "Cannot PUT a whole collection."});
	}
});

app.delete('/:collection/:entity', function(req, res) {
	var params = req.params;
	var collection = params.collection;
	var entity = params.entity;
	if (entity) {
		collectionDriver.delete(collection, entity, function(error, objs) {
			if (error)
				res.sendStatus(400, error);
			else
				res.sendStatus(200, objs);
		});
	} else {
		res.sendStatus(400, {"error" : "Cannot DELETE a whole collection."});
	}
});

/*
1)  app.use(callback) matches all requests. 
	When placed at the end of the list of app.use and app.verb statements, this callback becomes a catch-all.

2)  The call to res.render(view, params) fills the response body with output rendered from a templating engine. 
	A templating engine takes a template file called a “view” from disk and replaces variables 
	with a set of key-value parameters to produce a new document.
*/
app.use(function (req,res) { //1
    // res.render('404', {url:req.url}); //2
    res.send({'error': '404 not found'});
});

 
// Respond to HTTP requests by sending a 200 response code and writes page content into response
http.createServer(app).listen(app.get('port'), function() {
	console.log('Express server listening on port ' + app.get('port'))
});