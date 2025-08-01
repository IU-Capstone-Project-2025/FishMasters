create table if not exists fish (
    id serial primary key,
    name varchar(255) not null,
    photo bytea default null
);

create table if not exists caught_fish (
    id serial primary key,
    fisher varchar(255) not null,
    avg_weight double precision null,
    photo bytea default null,
    fishing_id integer not null references fishing(id),
    fish_id integer default null references fish(id)
    fish_name varchar(255) default null
);