package inno.fishmasters.controller;

import inno.fishmasters.dto.request.discussion.CreateMessageRequest;
import inno.fishmasters.dto.response.MessageResponse;
import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Message;
import inno.fishmasters.service.DiscussionService;
import inno.fishmasters.service.MessageService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.AllArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@AllArgsConstructor
@RestController
@RequestMapping("/api/discussion")
public class DiscussionController {
    
    private final DiscussionService discussionService;
    private final MessageService messageService;

    @Operation(summary = "Create a new discussion by waterId. Return discussion id")
    @PostMapping("/{waterId}")
    public ResponseEntity<Long> createDiscussion(@PathVariable Double waterId) {
        Discussion discussion = discussionService.createDiscussion(waterId);
        return ResponseEntity.ok(discussion.getId());
    }

    @Operation(summary = "Get all messages by discussionId")
    @GetMapping("/messages/{discussionId}")
    public ResponseEntity<List<MessageResponse>> getMessagesByDiscussionId(@PathVariable Long discussionId) {
        List<MessageResponse> messages = messageService.getAllMessagesByDiscussionId(discussionId);
        return ResponseEntity.ok(messages);
    }

    @Operation(summary = "Create a new message in discussion")
    @PostMapping("/messages/createMessage")
    public ResponseEntity<MessageResponse> createMessage(@RequestBody CreateMessageRequest request) {
        MessageResponse createdMessage = messageService.createMessage(request);
        return ResponseEntity.ok(createdMessage);
    }
    
}
