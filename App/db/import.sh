mongoimport --host localhost --db webratings --collection heroes --type json --file ./db/heroes.json --jsonArray
mongoimport --host localhost --db webratings --collection ratings --type json --file ./db/ratings.json --jsonArray
mongoimport --host localhost --db webratings --collection sites --type json --file ./db/sites.json --jsonArray