package com.reznok.helloworld;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api")
public class ChatController {

    private final LlmService llmService;

    public ChatController(LlmService llmService) {
        this.llmService = llmService;
    }

    @PostMapping("/chat")
    public ResponseEntity<ChatResponse> chat(
            @RequestBody ChatRequest request,
            @CookieValue(value = "chat-session", required = false) String sessionId
    ) {
        if (request.getMessage() == null || request.getMessage().isBlank()) {
            return ResponseEntity.badRequest().body(new ChatResponse("Empty message"));
        }

        boolean newSession = false;

        if (sessionId == null || sessionId.isBlank()) {
            sessionId = UUID.randomUUID().toString();
            newSession = true;
        }

        String reply = llmService.ask(sessionId, request.getMessage());

        ResponseEntity.BodyBuilder builder = ResponseEntity.ok();

        if (newSession) {
            ResponseCookie cookie = ResponseCookie.from("chat-session", sessionId)
                    .path("/")
                    .httpOnly(true)
                    .build();

            builder.header(HttpHeaders.SET_COOKIE, cookie.toString());
        }

        return builder.body(new ChatResponse(reply));
    }

    @PostMapping("/clear")
    public ResponseEntity<ChatResponse> clear(
            @CookieValue(value = "chat-session", required = false) String sessionId
    ) {
        if (sessionId != null && !sessionId.isBlank()) {
            llmService.clearMemory(sessionId);
        }

        return ResponseEntity.ok(new ChatResponse("Memory cleared"));
    }
}