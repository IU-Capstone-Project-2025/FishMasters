package inno.fishmasters.dto.request.discussion;

public record CreateMessageRequest(
    Long discussionId,
    String content,
    String fisherEmail
) {
}
