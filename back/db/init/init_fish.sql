create table if not exists fish (
    id serial primary key,
    name varchar(255) not null,
    avg_weight double precision null,
    photo bytea
);

create table if not exists caught_fish (
    id serial primary key,
    fishing_id integer not null references fishing(id),
    fish_id integer not null references fish(id)
);