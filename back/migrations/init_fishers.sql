CREATE TABLE IF NOT EXISTS fishers (
    email varchar(255) primary key unique not null,
    name varchar(255) not null,
    surname varchar(255) not null,
    password varchar(255) not null,
    score integer not null default 0,
    photo bytea default null,
 );