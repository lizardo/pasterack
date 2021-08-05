pasterack
=========

An evaluating [pastebin](http://www.pasterack.org) for Racket.

pkg dependencies: ring-buffer, redis, irc, memoize, graph, lang-file

Running locally
===============

1. Start a local Redis instance, e.g. using Docker:
```
docker run -p 6379:6379 --name redis-pasterack -d redis:alpine
```

2. Create a directory where various output files are stored:
```
mkdir tmp
```

3. Launch pasterack (replace `/path/to/racket` with the location where you
	 installed Racket):
```
PATH=/path/to/racket/bin racket pasterack.rkt
```

4. Open http://localhost:8000/ in your browser.
