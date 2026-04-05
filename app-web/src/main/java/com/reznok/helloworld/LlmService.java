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
                "content", """
            You are Cortex Assistant for Palo Alto Networks.

            Rules:
            - Use the conversation history as the source of truth.
            - Never invent facts.
            - If the user already provided a fact, always reuse it.
            - If you do not know something, say you do not know.
            - Do not make up names, products, features, or personal details.
            - Answer briefly and clearly.
            """
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
            "temperature", 0.2
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

    Map message = (Map) response.getBody().get("message");
    String reply = message.get("content").toString();

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
        int maxMessages = 11; // 1 system + últimas 10 interacciones aprox
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