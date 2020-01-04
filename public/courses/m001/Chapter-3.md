# Chpater 3 - Deeper Dive on the MongoDB Query Language

## Query Operators

- [Query Operators](https://docs.mongodb.com/manual/reference/operator/query/)
- [\$type](https://docs.mongodb.com/manual/reference/operator/query/type/)

```js
db.movieDetails.find(
  { runtime: { $gt: 90 } },
  { _id: 0, title: 1, runtime: 1 }
)

db.movieDetails.find(
  { runtime: { $gt: 90, $lte: 120 } },
  { _id: 0, title: 1, runtime: 1 }
)

db.movieDetails.find(
  { runtime: { $gte: 180 }, "tomato.meter": { $gte: 95 } },
  { _id: 0, title: 1, runtime: 1 }
)

db.movieDetails.find(
  { rated: { $ne: "unrated" } },
  { _id: 0, title: 1, runtime: 1 }
)

db.movieDetails.find(
  { cast: { $in: ["Jack Nicholson", "John Huston"] } },
  { _id: 0, title: 1 }
)

db.movieDetails.find(
  { "tomato.concensus": null }, // Return all documents with null value or documents without the "concensus" field
  { _id: 0, title: 1 }
)

db.movieDetails.find(
  { viewerRating: { $type: "int" }},
  { _id: 0, title: 1 }
)

db.movieDetails.find(
  { $or: [
    { "tomato.meter": { $gt: 95 }},
    { "metacritic": { $gt: 88 }}
  ]},
  { _id: 0, title: 1, metacritic: 1, "tomato.meter": 1 }
)

db.movieDetails.find(
  { $and: [
    { "metacritic": { $ne: null }},
    { "metacritic": { $exists: true }}
  ]},
  { _id: 0, title: 1, metacritic: 1 }
)

db.movieDetails.find(
  { genres: { $all: ["Comedy", "Crime", "Drama"] } },
  { _id: 0, title: 1, genres: 1 }
)

db.movieDetails.find(
  { countries: { $size: 1 } },
  { _id: 0, title: 1, countries: 1 }
)

db.movieDetails.find(
  { boxOffice: { $elemMatch: {"country": "Germany", "revenu": {$gt: 17}}},
  { _id: 0, title: 1, countries: 1 }
)

db.movieDetails.find(
  { "awards.text": { $regex: /^Won.*/ }},
  { _id: 0, title: 1, "awards.text": 1 }
)

```
