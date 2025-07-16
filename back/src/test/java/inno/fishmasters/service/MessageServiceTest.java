package inno.fishmasters.service;

import inno.fishmasters.dto.request.discussion.CreateMessageRequest;
import inno.fishmasters.dto.response.MessageResponse;
import inno.fishmasters.entity.Discussion;
import inno.fishmasters.entity.Message;
import inno.fishmasters.exception.DiscussionIsNotFoundException;
import inno.fishmasters.repository.DiscussionRepository;
import inno.fishmasters.repository.MessageRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class MessageServiceTest {

    @Mock
    private MessageRepository messageRepository;

    @Mock
    private DiscussionRepository discussionRepository;

    @InjectMocks
    private MessageService messageService;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void getAllMessagesByDiscussionId_success() {
        // given
        Long discussionId = 42L;
        Discussion discussion = new Discussion();
        discussion.setId(discussionId);

        Message m1 = new Message();
        m1.setId(1L);
        m1.setContent("Hello");
        m1.setFisherEmail("a@mail.com");
        m1.setCreatedAt(LocalDateTime.of(2025,7,1,12,0));
        m1.setDiscussion(discussion);

        Message m2 = new Message();
        m2.setId(2L);
        m2.setContent("World");
        m2.setFisherEmail("b@mail.com");
        m2.setCreatedAt(LocalDateTime.of(2025,7,1,12,5));
        m2.setDiscussion(discussion);

        when(discussionRepository.findById(discussionId)).thenReturn(Optional.of(discussion));
        when(messageRepository.findAllByDiscussion(discussion)).thenReturn(List.of(m1, m2));

        // when
        List<MessageResponse> responses = messageService.getAllMessagesByDiscussionId(discussionId);

        // then
        assertEquals(2, responses.size());
        assertEquals(1L, responses.get(0).id());
        assertEquals("Hello", responses.get(0).content());
        assertEquals("a@mail.com", responses.get(0).fisherEmail());
        assertEquals(LocalDateTime.of(2025,7,1,12,0), responses.get(0).createdAt());
        assertEquals(2L, responses.get(1).id());
        assertEquals("World", responses.get(1).content());

        verify(discussionRepository).findById(discussionId);
        verify(messageRepository).findAllByDiscussion(discussion);
    }

    @Test
    void getAllMessagesByDiscussionId_notFound() {
        Long discussionId = 99L;
        when(discussionRepository.findById(discussionId)).thenReturn(Optional.empty());

        assertThrows(DiscussionIsNotFoundException.class,
                () -> messageService.getAllMessagesByDiscussionId(discussionId));
        verify(discussionRepository).findById(discussionId);
        verifyNoMoreInteractions(messageRepository);
    }

    @Test
    void createMessage_success() {
        // given
        Long discussionId = 5L;
        String content = "New message";
        String email = "user@mail.com";
        CreateMessageRequest request = new CreateMessageRequest(discussionId, content, email);

        Discussion discussion = new Discussion();
        discussion.setId(discussionId);

        Message saved = new Message();
        saved.setId(100L);
        saved.setDiscussion(discussion);
        saved.setContent(content);
        saved.setFisherEmail(email);
        saved.setCreatedAt(LocalDateTime.of(2025,7,2,8,30));

        when(discussionRepository.findById(discussionId)).thenReturn(Optional.of(discussion));
        // capture the Message passed to save(...) and return our saved stub
        ArgumentCaptor<Message> captor = ArgumentCaptor.forClass(Message.class);
        when(messageRepository.save(captor.capture())).thenReturn(saved);

        // when
        MessageResponse response = messageService.createMessage(request);

        // then
        Message toSave = captor.getValue();
        assertEquals(content, toSave.getContent());
        assertEquals(email, toSave.getFisherEmail());
        assertEquals(discussion, toSave.getDiscussion());
        assertNotNull(toSave.getCreatedAt());

        assertEquals(100L, response.id());
        assertEquals(content, response.content());
        assertEquals(email, response.fisherEmail());
        assertEquals(LocalDateTime.of(2025,7,2,8,30), response.createdAt());

        verify(discussionRepository).findById(discussionId);
        verify(messageRepository).save(any(Message.class));
    }

    @Test
    void createMessage_discussionNotFound() {
        Long discussionId = 7L;
        CreateMessageRequest request = new CreateMessageRequest(discussionId, "X", "y@mail.com");

        when(discussionRepository.findById(discussionId)).thenReturn(Optional.empty());

        assertThrows(DiscussionIsNotFoundException.class,
                () -> messageService.createMessage(request));
        verify(discussionRepository).findById(discussionId);
        verifyNoInteractions(messageRepository);
    }
}