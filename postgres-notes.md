# postgresql-notes
Just my cheating notes for Postgres

## psql functions

### Remove wrapping and '+' character from long string output
```
pset format unaligned
pset expanded off
```

### Replace carriage returns with ' '.
```
select regexp_replace(expression, E'[\\n\\r]+', ' ', 'g') from icap_rules where provider='DallasCounty';
```

### Time
#### Timestamps
Using a timestamp offset from the current time.
```
select id, identifier, received_at from alerts where active=false and received_at < current_timestamp - interval '72 hours' order by received_at desc;
```

#### Return the difference between current time and TIMESTAMP column in hours
```
select created_at, secs_to_next_beat, extract(epoch from now() - created_at)/3600 as diff_in_hours from door_event;
```
### Changing a postgres user password.
```
alter user <username> with password 'newpassword';
```
### pg_dump
pg_dump has several options. The most common ones are:
```
pg_dump -C -c --if-exists --host= --dbname= --username= -f /tmp/data.sql
```
1. -C = include the CREATE DATABASE command
1. -c = clean/drop database  objects before recreating
1. --if-exists = use IF EXISTS when dropping objects

## Stored Procedures and Triggers

### Update a TIMESTAMP each time an update is performed
```
CREATE OR REPLACE FUNCTION update_last_updated_at()
RETURNS TRIGGER AS $$
BEGIN
   NEW.last_updated_at = now();
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER campus_last_updated_at BEFORE UPDATE ON campus
   FOR EACH ROW
      EXECUTE PROCEDURE update_last_updated_at();
```

### Updating a value in a row based on another value.
```
CREATE OR REPLACE FUNCTION set_deleted_at()
RETURNS TRIGGER AS $$
BEGIN
   IF NEW.is_deleted = TRUE THEN
      NEW.deleted_at = now();
   END IF;
   RETURN NEW;
END;
$$ language 'plpgsql';
```
## Performance Tuning
To do any useful performance tuning you need the [pg_stat_statements](https://www.postgresql.org/docs/current/static/pgstatstatements.html) module installed and also possibly the [postgres
statistics collector](https://www.postgresql.org/docs/current/static/monitoring-stats.html).

### pg_stat_statements
This module must be loaded at startup of the server in the shared_preload_libraries directive in postgresql.conf file.
```
shared_preload_libraries = 'pg_stat_statements'
```
Since it must load at startup you need to bounce your psql server `/etc/init.d/postgresql restart`. Once restarted, let
it run for a while to collect data.

Once this is done you can log into your database and run `CREATE EXTENSION pg_stat_statements;`. Once this is
done, if you run a \dv you should see the view pg_stat_statements.

In docker it is a bit trickier because the preload isn't burned into the postgres image. So the only thing I can
think of doing is:
```
sudo docker run -ti postgres /bin/bash
vi /etc/postgres/postgres.conf  # adding the shared_preload_libraries= line
/etc/init.d/postgres start
```
As soon as you remove the container you'd have to perform the steps again.

Once you have it installed you can query the view to try to find the slow running queries.

```
select queryid,
       substring(query from 1 for 40) as query,
       calls,
       total_time,
       min_time,
       max_time,
       mean_time 
       from pg_stat_statements order by mean_time;
```
1. queryid - is the unique id of the query
1. query - the actual query body
1. calls - how many times the query has been executed
1. total_time - total accumulated time (ms) of this query
1. min_time - the quickest time the query has executed.
1. max_time - the slowest time the query has executed.
1. mean_time - the mean time. (mean_time X calls) = total_time

total_time and mean_time are probably the columns that will point you best to see which queries are real pigs.

### postgres statistics collector
This is very useful for index tuning. It will help find queries that are missing indices and also indices which
are unused.

Similar to ps_stat_statements you need to activate this at server startup. In the postgresql.conf file there are 
5 different options which can be activated. Note, these have overhead, so you probably don't want to leave these
on in production. The ones we are most interested in are:
```
track_activities=on
track_counts=on
```
Restart the server and let the thing run for a while so it can gather statistics.

Now to look for missing indices run this query:
```
SELECT relname,
       seq_scan-idx_scan AS too_much_seq,
       CASE WHEN seq_scan-idx_scan>0
       THEN
          'Probably'
       ELSE
          'No'
       END AS NEEDS_INDEX,
       pg_relation_size(relname::regclass) AS rel_size,
       seq_scan,
       idx_scan,
       (seq_scan*100.0)/idx_scan::float as seq_to_idx_pct
       FROM pg_stat_all_tables
       WHERE schemaname='public' AND
             pg_relation_size(relname::regclass)>80000
       ORDER BY too_much_seq DESC;
```
If you have more sequential scans than index scans that indicates an index will help. It won't tell you which
columns to index. That you have to do on your own.

Now to look for unused indices run this query:
```
SELECT indexrelid::regclass as index,
       relid::regclass as table,
       'DROP INDEX ' || indexrelid::regclass || ';' as drop_statement
       FROM pg_stat_user_indexes 
          JOIN pg_index USING (indexrelid) 
       WHERE idx_scan = 0 AND indisunique is false;
```
Should list unused indices.
### Helpful Links

1. [https://www.geekytidbits.com/performance-tuning-postgres/}(https://www.geekytidbits.com/performance-tuning-postgres/)
