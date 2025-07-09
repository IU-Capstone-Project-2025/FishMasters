create table if not exists message(
    id bigserial primary key,
    content varchar not null,
    created_at timestamp not null default current_timestamp,
    fisher_email varchar(255) not null
        references fishers(email)
        on delete set null,
    discussion_id bigint not null
        references discussion(id)
        on delete cascade
)