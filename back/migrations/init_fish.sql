create table if not exists fish (
    id serial primary key,
    name varchar(255) not null,
    photo varchar default null
);

create table if not exists caught_fish (
    id serial primary key,
    fisher varchar(255) not null,
    avg_weight double precision null,
    fishing_id integer not null references fishing(id),
    fish_id integer not null references fish(id)
);