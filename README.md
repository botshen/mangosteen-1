docker run -d --name db-for-mangosteen -e POSTGRES_USER=mangosteen -e POSTGRES_PASSWORD=123456 -e POSTGRES_DB=mangosteen_dev -e PGDATA=/var/lib/postgresql/data/pgdata -v mangosteen-data:/var/lib/postgresql/data --network=network1 postgres:14


EDITOR="code --wait" bin/rails credentials:edit

bin/rake docs:generate 

open doc/api/index.html 

bin/rails g model tag user:references name:string sign:string deleted_at:datetime

bin/rails g controller api/v1/tags_controller
