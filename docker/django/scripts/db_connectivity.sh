#!/bin/bash
set -e
cmd="$@"
 
function postgres_ready(){
python << END
import sys
from urllib import parse
import psycopg2
try:
   result = parse.urlparse("$DATABASE_URL")
   print(result)
   username = result.username
   password = result.password
   database = result.path[1:]
   hostname = result.hostname
   port = result.port
  
   conn = psycopg2.connect(
       database = database,
       user = username,
       password = password,
       host = hostname,
       port = port
   )
  
except psycopg2.OperationalError as e:
   print(e)
   sys.exit(-1)
sys.exit(0)
END
}
 
until postgres_ready; do
 >&2 echo "Postgres is unavailable - sleeping"
 sleep 1
done
 
>&2 echo "Postgres is up - continuing..."
exec $cmd
