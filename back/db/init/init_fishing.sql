create table if not exists fishing (
    id serial priamary key,
    fisher_email varchar(255) not null references fishers(email),
    water_id integer not null references waters(id),
    start_time timestamp not null,
    end_time timestamp null,
);
