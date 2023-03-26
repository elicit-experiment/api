namespace :docker do
  namespace :db do
    task backup: :environment do
      Rails.application.eager_load!
      #`docker exec -i postgres apk add --no-cache postgresql-client`
      #`docker exec -e PGPASSWORD=#{ENV['POSTGRES_PASSWORD']} -i postgres pg_dump -U elicit #{ENV['POSTGRES_DB']} >postgres-backup-sql`
       `docker exec -e PGPASSWORD=#{ENV['POSTGRES_PASSWORD']} -i postgres pg_dumpall -U elicit >postgres-backup.sql`
      #`| gzip -9 > postgres-backup.sql.gz`
    end


    task restore: :environment do
      Rails.application.eager_load!
      puts ActiveRecord::Base.connection.select_value('SELECT version()')
      `docker cp postgres-backup.sql postgres15:/var/lib/postgresql/backups/`
      `docker exec -e PGPASSWORD=#{ENV['POSTGRES_PASSWORD']} -i postgres15 psql -U elicit -f /var/lib/postgresql/backups/postgres-backup.sql postgres`
    end

  end
end
