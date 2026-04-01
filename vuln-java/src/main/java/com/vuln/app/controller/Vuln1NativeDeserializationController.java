package com.vuln.app.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.util.Base64;

@Slf4j
@Controller
@RequestMapping("/vuln1")
public class Vuln1NativeDeserializationController {

    @GetMapping
    public String index(Model model) {
        model.addAttribute("vulnName", "Java原生反序列化漏洞");
        model.addAttribute("vulnDesc", "使用Apache Commons Collections 3.1的Java原生反序列化漏洞");
        model.addAttribute("riskLevel", "高危");
        return "vuln1";
    }

    @PostMapping("/deserialize")
    @ResponseBody
    public String deserialize(@RequestBody String data, HttpServletResponse response) {
        try {
            byte[] decoded = Base64.getDecoder().decode(data);
            ByteArrayInputStream bis = new ByteArrayInputStream(decoded);
            ObjectInputStream ois = new ObjectInputStream(bis);
            Object obj = ois.readObject();
            ois.close();
            return "反序列化成功！对象: " + obj.toString();
        } catch (Exception e) {
            log.error("反序列化失败", e);
            return "反序列化失败: " + e.getMessage();
        }
    }

    @GetMapping("/cookie")
    @ResponseBody
    public String cookieVuln(@CookieValue(value = "user", required = false) String userCookie,
                            HttpServletResponse response) {
        if (userCookie != null) {
            try {
                byte[] decoded = Base64.getDecoder().decode(userCookie);
                ByteArrayInputStream bis = new ByteArrayInputStream(decoded);
                ObjectInputStream ois = new ObjectInputStream(bis);
                Object obj = ois.readObject();
                ois.close();
                return "Cookie反序列化成功！对象: " + obj.toString();
            } catch (Exception e) {
                log.error("Cookie反序列化失败", e);
                return "Cookie反序列化失败: " + e.getMessage();
            }
        }
        return "未检测到user Cookie";
    }

    @PostMapping("/profile")
    @ResponseBody
    public String updateProfile(@RequestBody String profileData) {
        try {
            byte[] decoded = Base64.getDecoder().decode(profileData);
            ByteArrayInputStream bis = new ByteArrayInputStream(decoded);
            ObjectInputStream ois = new ObjectInputStream(bis);
            Object obj = ois.readObject();
            ois.close();
            return "个人资料更新成功！数据: " + obj.toString();
        } catch (Exception e) {
            log.error("个人资料反序列化失败", e);
            return "个人资料更新失败: " + e.getMessage();
        }
    }
}
