import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.*;

@Service
public class LlmService {

    @Value("${llm.url}")
    private String llmUrl;

    @Value("${llm.model}")
    private String llmModel;

    private final RestTemplate restTemplate = new RestTemplate();

    public String ask(String userMessage) {
        try {
            Map<String, Object> payload = new HashMap<>();
            payload.put("model", llmModel);
            payload.put("stream", false);

            List<Map<String, String>> messages = new ArrayList<>();
            messages.add(Map.of("role", "user", "content", userMessage));
            payload.put("messages", messages);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> entity = new HttpEntity<>(payload, headers);

            System.out.println("LLM URL: " + llmUrl);
            System.out.println("LLM MODEL: " + llmModel);

            ResponseEntity<Map> response = restTemplate.exchange(
                    llmUrl,
                    HttpMethod.POST,
                    entity,
                    Map.class
            );

            System.out.println("BODY: " + response.getBody());

            if (response.getBody() == null || response.getBody().get("message") == null) {
                throw new RuntimeException("Invalid response from LLM: " + response.getBody());
            }

            Map message = (Map) response.getBody().get("message");
            Object content = message.get("content");

            if (content == null) {
                throw new RuntimeException("Missing content in LLM response: " + response.getBody());
            }

            return content.toString();

        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }
}