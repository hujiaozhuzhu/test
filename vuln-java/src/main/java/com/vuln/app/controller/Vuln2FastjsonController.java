package com.vuln.app.controller;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Slf4j
@Controller
@RequestMapping("/vuln2")
public class Vuln2FastjsonController {

    @GetMapping
    public String index(Model model) {
        model.addAttribute("vulnName", "Fastjson反序列化漏洞");
        model.addAttribute("vulnDesc", "使用Fastjson 1.2.24的JNDI注入反序列化漏洞");
        model.addAttribute("riskLevel", "高危");
        return "vuln2";
    }

    @PostMapping("/parse")
    @ResponseBody
    public String parseJson(@RequestBody String jsonData) {
        try {
            JSONObject jsonObject = JSON.parseObject(jsonData);
            return "JSON解析成功！对象: " + jsonObject.toString();
        } catch (Exception e) {
            log.error("JSON解析失败", e);
            return "JSON解析失败: " + e.getMessage();
        }
    }

    @GetMapping("/user")
    @ResponseBody
    public String getUser(@RequestParam String data) {
        try {
            JSONObject user = JSON.parseObject(data);
            return "用户信息: " + user.toString();
        } catch (Exception e) {
            log.error("解析用户数据失败", e);
            return "解析失败: " + e.getMessage();
        }
    }

    @PostMapping("/config")
    @ResponseBody
    public String updateConfig(@RequestBody String configData) {
        try {
            JSONObject config = JSON.parseObject(configData);
            return "配置更新成功！配置: " + config.toString();
        } catch (Exception e) {
            log.error("配置反序列化失败", e);
            return "配置更新失败: " + e.getMessage();
        }
    }
}
