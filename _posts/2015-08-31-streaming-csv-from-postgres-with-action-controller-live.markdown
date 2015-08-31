---
layout: post
published: true
title: Streaming CSV from Postgres with ActionController::Live in Rails
date: '2015-08-31 09:57:41 -0700'
tags:
- rails
- postgres
---
A recent client of mine needed an app to help him build bite-sized CSV files
from a large PostgreSQL table. The problem was simple enough and it takes
little time to write a simple Rails action to query a table, generate CSV from
the objects in memory and flush it out to the client. Writing an app to do this
one thing using a traditional Rails action is a matter of just a few hours.

But our client wanted to run queries that could potentially return 10, 20 or
even 100 thousand records. When dealing with large numbers of records,
performance can suffer because the application has to spend a lot of CPU time
taking all those in-memory records and transforming them into a bunch of
in-memory strings for the CSV file. Doing this in the application and entirely
before sending the response means the app consumes a lot of memory and a lot of
CPU time. Eventually, these responses would come through, but when you start
talking about 30+ second response times, you can run into trouble from both
users who don't want to wait so long for responses and application environments
where resource use and extended response times are unacceptable or maybe even
disallowed.

Since I was querying a pretty large Postgres table (200M+ rows) with a fairly
involved query type (geographic proximity), I spent a lot of time debugging the
query before realizing the problem was really in my own app. After I realized
what was going on, I set about looking for a better way to build the CSV and
send it to the waiting client. I found two things. First, I found that Postgres
can directly generate CSV from any query and stream it back on the socket. And
second, I found that Rails can stream the response coming from Postgres,
directly to the end-user waiting on the other end of the HTTP connection using
ActionController::Live.

Here's how it works. I've taken all the application-specific content out of
here so you can more clearly see this technique:

~~~ ruby
class SearchController < ApplicationController
  include ActionController::Live

  def run
    response.headers['Content-Disposition'] = 'attachment; filename="filename.csv"'
    response.headers['Content-Type'] = 'text/csv'

    conn = ActiveRecord::Base.connection.instance_variable_get(:@connection)
    conn.copy_data "COPY ( #{query} ) TO STDOUT WITH CSV HEADER;" do
      while row=conn.get_copy_data
        response.stream.write row
      end
    end
  ensure
    response.stream.close
  end
end
~~~

To tell Rails you want to stream responses from this controller, include
ActionController::Live at the top. Basically, this tells Rails you want to use
chunked encoding for your HTTP responses. And in your action, your response
object now has a special stream property which is an IO-like object
representing the outward-facing HTTP response. Anything you write to the stream
is sent immediately to the user agent.

That's why it's important to set any headers you need to set before writing any
of the response body. In this case, I'm using the Content-Disposition header so
browsers know to treat the response as a file download.

I am using a bit of a hack to grab hold of the raw Postgres connection
underlying the ActiveRecord connection because I don't know a better way.
copy_data is a method the Postgres gem provides which invokes an SQL COPY
command. It typically would copy query results to a file, but since I've
specified "TO STDOUT" I'll be able to read the response right here from the
Postgres connection using get_copy_data. As a bonus, I can ask for the results
in CSV format and not have to worry about converting it myself. Now that
Postgres is generating CSV for me, all my action needs to do is read the lines
from the Postgres socket and write then to the HTTP response stream.

The results shocked me. Queries for even large amounts of data were
imperceptibly fast. The download starts so quickly its not even worth measuring
and the data transfer bottleneck is certainly my own middle-tier cable Internet
connection.
