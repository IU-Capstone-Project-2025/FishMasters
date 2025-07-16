package inno.fishmasters.service;


import inno.fishmasters.dto.request.discussion.CreateMessageRequest;
import inno.fishmasters.dto.response.MessageResponse;
import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Message;
import inno.fishmasters.exception.DiscussionIsNotFoundException;
import inno.fishmasters.repository.DiscussionRepository;
import inno.fishmasters.repository.MessageRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.log4j.Log4j2;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Log4j2
@Service
@RequiredArgsConstructor
public final class MessageService {

    private final MessageRepository messageRepository;
    private final DiscussionRepository discussionRepository;

    public List<MessageResponse> getAllMessagesByDiscussionId(Long discussionId) {

        Discussion discussion = discussionRepository.findById(discussionId)
                .orElseThrow(() -> new DiscussionIsNotFoundException("Discussion not found with id: " + discussionId));
        return messageRepository.findAllByDiscussion(discussion).stream().map(
                el -> new MessageResponse(
                        el.getId(),
                        el.getContent(),
                        el.getFisherEmail(),
                        el.getCreatedAt()
                )
        ).toList();
    }

    public MessageResponse createMessage(CreateMessageRequest request) {

        Discussion discussion = discussionRepository.findById(request.discussionId())
                .orElseThrow(() -> new DiscussionIsNotFoundException("Discussion not found with id: " + request.discussionId()));

        Message message = messageRepository.save(new Message(
                request.content(),
                discussion,
                request.fisherEmail(),
                LocalDateTime.now()
        ));
        return new MessageResponse(
                message.getId(),
                message.getContent(),
                message.getFisherEmail(),
                message.getCreatedAt()
        );

    }

}
