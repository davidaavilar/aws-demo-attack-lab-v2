package com.reznok.helloworld;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.concurrent.ConcurrentHashMap;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class LlmService {

    @Value("${llm.url}")
    private String llmUrl;

    @Value("${llm.model}")
    private String llmModel;

    private final RestTemplate restTemplate = new RestTemplate();

    private final Map<String, List<Map<String, String>>> memory = new ConcurrentHashMap<>();
    private final Map<String, Map<String, String>> userFacts = new ConcurrentHashMap<>();

    public String ask(String sessionId, String userMessage) {
        List<Map<String, String>> history = memory.computeIfAbsent(sessionId, k -> new ArrayList<>());
        Map<String, String> facts = userFacts.computeIfAbsent(sessionId, k -> new HashMap<>());

        extractFacts(facts, userMessage);

        String systemPrompt = buildSystemPrompt(facts);

        if (history.isEmpty()) {
            history.add(Map.of(
                    "role", "system",
                    "content", systemPrompt
            ));
        } else {
            history.set(0, Map.of(
                    "role", "system",
                    "content", systemPrompt
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
                "temperature", 0.1
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
        userFacts.remove(sessionId);
    }

    private String buildSystemPrompt(Map<String, String> facts) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("You are Cortex Assistant for Palo Alto Networks. ");
        prompt.append("Answer briefly, clearly, and accurately. ");
        prompt.append("Use the conversation history and known user facts as the source of truth. ");
        prompt.append("Never invent names, facts, product capabilities, or personal details. ");
        prompt.append("If you do not know something, say you do not know. ");

        if (facts.containsKey("name")) {
            prompt.append("The user's name is ").append(facts.get("name")).append(". ");
        }

        return prompt.toString();
    }

    private void extractFacts(Map<String, String> facts, String userMessage) {
        Pattern pattern = Pattern.compile("(?i)\\b(?:my name is|i am|i'm|me llamo|soy)\\s+([A-Za-zÁÉÍÓÚáéíóúÑñ]+)");
        Matcher matcher = pattern.matcher(userMessage.trim());

        if (matcher.find()) {
            facts.put("name", matcher.group(1));
        }
    }

    private void trimHistory(List<Map<String, String>> history) {
        int maxMessages = 11;
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