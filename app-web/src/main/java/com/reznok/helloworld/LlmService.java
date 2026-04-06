package com.reznok.helloworld;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class LlmService {

    @Value("${llm.url}")
    private String llmUrl;

    @Value("${llm.model}")
    private String llmModel;

    private final RestTemplate restTemplate = new RestTemplate();

    private final Map<String, List<Map<String, String>>> memory = new ConcurrentHashMap<>();

    public String ask(String sessionId, String userMessage) {
        List<Map<String, String>> history = memory.computeIfAbsent(sessionId, k -> new ArrayList<>());

        if (history.isEmpty()) {
            history.add(Map.of(
                    "role", "system",
                    "content", "You are Cortex Assistant for Palo Alto Networks. " +
                            "You must use the conversation history as the single source of truth. " +
                            "If the user states a fact about themselves, you must remember it and reuse it consistently. " +
                            "Never contradict prior user-provided facts. " +
                            "Never say you do not know a fact if the user already told you. " +
                            "When the user asks about their name, identity, or previous message, answer only from the conversation history. " +
                            "Do not invent information. " +
                            "Be brief and precise."
            ));
        }

        history.add(Map.of(
                "role", "user",
                "content", userMessage
        ));

        trimHistory(history);

        Map<String, Object> payload = new HashMap<>();
        payload.put("model", llmModel);
        payload.put("stream", false);
        payload.put("messages", history);
        payload.put("options", Map.of(
                "temperature", 0.0
        ));

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

        ResponseEntity<Map> response = restTemplate.exchange(
                llmUrl,
                HttpMethod.POST,
                entity,
                Map.class
        );

        Map body = response.getBody();
        if (body == null || body.get("message") == null) {
            return "I could not generate a response.";
        }

        Map message = (Map) body.get("message");
        Object content = message.get("content");

        if (content == null) {
            return "I could not generate a response.";
        }

        String reply = content.toString();

        history.add(Map.of(
                "role", "assistant",
                "content", reply
        ));

        trimHistory(history);

        return reply;
    }

    public void clearMemory(String sessionId) {
        memory.remove(sessionId);
    }

    private void trimHistory(List<Map<String, String>> history) {
        int maxMessages = 21; // 1 system + últimas 20 interacciones aprox

        if (history.size() <= maxMessages) {
            return;
        }

        Map<String, String> systemMessage = history.get(0);
        List<Map<String, String>> trimmed = new ArrayList<>();
        trimmed.add(systemMessage);

        int start = Math.max(1, history.size() - (maxMessages - 1));
        trimmed.addAll(history.subList(start, history.size()));

        history.clear();
        history.addAll(trimmed);
    }
}