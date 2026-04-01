package com.vuln.app.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@Slf4j
@Controller
@RequestMapping("/vuln3")
public class Vuln3JacksonController {

    private final ObjectMapper objectMapper = new ObjectMapper();

    public Vuln3JacksonController() {
        objectMapper.enableDefaultTyping(ObjectMapper.DefaultTyping.NON_FINAL);
        objectMapper.disable(SerializationFeature.FAIL_ON_EMPTY_BEANS);
    }

    @GetMapping
    public String index(Model model) {
        model.addAttribute("vulnName", "Jackson反序列化漏洞");
        model.addAttribute("vulnDesc", "使用Jackson 2.9.8的CVE-2017-7525漏洞");
        model.addAttribute("riskLevel", "中高危");
        return "vuln3";
    }

    @PostMapping("/deserialize")
    @ResponseBody
    public String deserialize(@RequestBody String jsonData) {
        try {
            Object obj = objectMapper.readValue(jsonData, Object.class);
            return "反序列化成功！对象: " + obj.toString();
        } catch (IOException e) {
            log.error("Jackson反序列化失败", e);
            return "反序列化失败: " + e.getMessage();
        }
    }

    @GetMapping("/data")
    @ResponseBody
    public String getData(@RequestParam String data) {
        try {
            Object obj = objectMapper.readValue(data, Object.class);
            return "数据解析成功！对象: " + obj.toString();
        } catch (IOException e) {
            log.error("数据解析失败", e);
            return "解析失败: " + e.getMessage();
        }
    }

    @PostMapping("/settings")
    @ResponseBody
    public String updateSettings(@RequestBody String settingsData) {
        try {
            Object settings = objectMapper.readValue(settingsData, Object.class);
            return "设置更新成功！设置: " + settings.toString();
        } catch (IOException e) {
            log.error("设置反序列化失败", e);
            return "设置更新失败: " + e.getMessage();
        }
    }
}
