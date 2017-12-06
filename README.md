# YVFourSquareTrendingVenues

- Its an app using FourSquare API i.e. Trending (venues/trending) and Search (venues /search)
- It will Fetch first (X&lt;=50) trending venues near user’s current location if the location is available else hardcode near Gurugram location.
- The user can search for venues using the search API. Results will be limited to (X&lt;=100) venues.
- Once the user searches the venue, results will be cached for X days and will be displayed to the user if he/she searches for the same query.
- Minimum character limit to fetch the results from search is: (X >= 3).
