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
                    "content", "Eres un asistente de Productos de Cortex de Palo Alto Networks. Responde corto y claro. Maximo 60 caracteres"
            ));
        }

        history.add(Map.of("role", "user", "content", userMessage));

        Map<String, Object> payload = new HashMap<>();
        payload.put("model", llmModel);
        payload.put("stream", false);
        payload.put("messages", history);

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

        history.add(Map.of("role", "assistant", "content", reply));

        return reply;
    }

    public void clearMemory(String sessionId) {
        memory.remove(sessionId);
    }
}