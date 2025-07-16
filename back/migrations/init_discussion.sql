create table if not exists discussion (
    id bigserial primary key,
    water_id double precision
        not null unique references waters(id)
        on delete cascade
)