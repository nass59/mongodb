# Chapter 2 - The MongoDB Query Language + Atlas

## Connecting to Our Class Atlas Cluster from the mongo Shell

```
mongo "mongodb://cluster0-shard-00-00-jxeqq.mongodb.net:27017,cluster0-shard-00-01-jxeqq.mongodb.net:27017,cluster0-shard-00-02-jxeqq.mongodb.net:27017/test?replicaSet=Cluster0-shard-0" --authenticationDatabase admin --ssl --username m001-student --password m001-mongodb-basics
```

### Other commands

```
show databases                // Show all databases
use video                     // Change database
show collections              // Show all collections in a database
db.movies.find().pretty()     // Get All movies
```

> __Problem__:
When connecting to an Atlas cluster using the shell, why do we provide the hostnames for all nodes when we launch mongo? Choose the best answer from the choices below.

> __Response__:
So that if the primary node goes down, the shell can connect to other nodes in the cluster instead

## Creating an Atlas Sandbox Cluster

- [Create Atlas Cluster](https://cloud.mongodb.com/links/registerForAtlas)

db.moviesScratch.insertOne({title: "Star Trek II: The Wrarth of Khan", year: 1982, imdb:"tt0084726"})

## Insert

> __Default: order insert. Once there is an error the script stop.__

The unordered order will continue the script even if there are errors.

## Query

> In shell don't forget the quotes

```
// Return movies with exactly these 2 actors in that order.
db.movies.find({cast: ["Jeff Bridges", "Tim Robbins"]})

// Return movies with Jeff Bridges in the cast.
db.movies.find({cast: "Jeff Bridges"})

// Return movies with Jeff Bridges as the main actor
db.movies.find({"cast.0": "Jeff Bridges"})

db.movies.find({genre: "Action, Adventure"}, {title: 1})
db.movies.find({genre: "Action, Adventure"}, {title: 1, _id:0})
```

## Update

```js
db.movieDetails.updateOne({
  title: "The Martian"
}, {
  $set: {
    poster: "http://images-of-matian.com/img.jpg"
  }
});

db.movieDetails.updateOne({
  title: "The Martian"
}, {
  $set: {
    "awards": {
      "win": 8,
      "nomination": 14,
      "text": "Nominated for 3 Golden Globes. Another 8 wins & 14 nominations."
    }
  }
});

db.movieDetails.updateOne({
  title: "The Martian"
}, {
  $inc: {
    "tomato.reviews": 3,
    "tomato.userReviews": 25
  }
});

db.movieDetails.updateOne({
  title: "The Martian"
}, {
  $push: {
    reviews: {
      rating: 4.5,
      date: ISODate("2016-01-12T09:00:00Z"),
      text: "Very good!"
    }
  }
});

db.movieDetails.updateMany({
  rated: null
}, {
  $unset: {
    rated: ""
  }
});

db.movieDetails.updateMany({
  "imdb.id": id
}, {
  $set: data
}, {
  upsert: true // avoid duplication. If document already exists, it will be updated
});
```

[Update operators](https://docs.mongodb.com/manual/reference/operator/update/)