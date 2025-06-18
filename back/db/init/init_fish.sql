create table if not exists fish (
    id serial primary key,
    name varchar(255) not null,
    avg_weight double precision not null,
    photo bytea
);