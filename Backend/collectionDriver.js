/*
Import the ObjectID function from the MongoDB package. 

Note: If you’re familiar with traditional databases, you probably understand the term “primary key”. 
MongoDB has a similar concept: by default, new entities are assigned a unique _id field of datatype ObjectID 
	that MongoDB uses for optimized lookup and insertion. 
Since ObjectID is a BSON type and not a JSON type, you’ll have to convert any incoming strings to 
	ObjectIDs if they’re to be used when comparing against an “_id” field.
*/
var ObjectID = require('mongodb').ObjectID;


/*
This function defines the CollectionDriver "class" constructor method; it stores a MongoDB client instance for later use.
*/
CollectionDriver = function(db) {
  this.db = db;
};


/*
This section defines a helper method getCollection to obtain a Mongo collection by name. You define class methods by adding functions to prototype. 

db.collection(name,callback) fetches the collection object and returns the collection — or an error — to the callback.
*/
CollectionDriver.prototype.getCollection = function(collectionName, callback) {
	this.db.collection(collectionName, function(error, theCollection) {
		if (error)
			callback(error);
		else
			callback(null, theCollection);
	});
};

/*
A: gets the collection on this line, and if there is no error, calls find() on line B.
B: returns all found objects in a data cursor format. Using the cursor, it can be used to iterate over matching objects.

toArray() organizes all the results in an array and passes it to the callback.
The final callback then returns to the caller with either an error or all of the found objects in the array.
*/
CollectionDriver.prototype.readAll = function(collectionName, callback) {
	this.getCollection(collectionName, function(error, theCollection) {
		if (error)
			callback(error);
		else {
			theCollection.find().toArray(function(error, results) {
				if (error)
					callback(error);
				else
					callback(null, results);
			});
		}
	});
};


/*
A: CollectionDriver.prototype.get obtains a single item from a collection by its _id

MongoDB stores _id fields as BSON type ObjectID.
ObjectID() is persnickety and requires the appropriate hex string or it will return an error: hence, the regex check up front in line B.

Note: Reading from a non-existent collection or entity is not an error – the MongoDB driver just returns an empty container.
*/
CollectionDriver.prototype.read = function(collectionName, id, callback) {	// A
	this.getCollection(collectionName, function(error, theCollection) {
		if (error)
			callback(error);
		else {
			var checkforHexRegExp = new RegExp("^[0-9a-fA-F]{24}$");

			if (!checkforHexRegExp.test(id))
				callback({"error": "invalid id"});
			else {
				theCollection.findOne({'_id': ObjectID(id)}, function(error, data) {
					if (error)
						callback(error);
					else
						callback(null, data);
				});
			}
		}
	});
}


CollectionDriver.prototype.create = function(collectionName, obj, callback) {
	this.getCollection(collectionName, function(error, theCollection) {	// Retrieve the collection object
		if (error)
			callback(error);
		else {
			obj.createdAt = new Date();	// Takes supplied entity and adds field to record date it was created
			console.log(obj);
			theCollection.insert(obj, function() {	// Insert modified object back into collection (automatically adds _id as well)
				callback(null, obj);
			});
		}
	});
}

CollectionDriver.prototype.update = function(collectionName, obj, entityID, callback) {	// Notice this update function replaces whatever was there before
	this.getCollection(collectionName, function(error, theCollection) {
		if (error)
			callback(error);
		else {
			obj._id = ObjectID(entityID);	// Convert to a real object ID
			obj.updatedAt = new Date();	// Adds an updated field with the time the object is modified
			theCollection.save(obj, function(error, doc) {	// 
				if (error)
					callback(error);
				else
					callback(null, obj);
			});
		}
	});
}

CollectionDriver.prototype.delete = function(collectionName, entityID, callback) {
	this.getCollection(collectionName, function(error, theCollection) {
		if (error)
			callback(error);
		else {
			theCollection.remove({'_id': ObjectID(entityID)}, function(error, doc) {
				if (error)
					callback(error);
				else
					callback(null, doc);
			});
		}
	});
}

/* This line declares the exposed, or exported, entities to other applications that list collectionDriver.js as a required module. */
exports.CollectionDriver = CollectionDriver;

