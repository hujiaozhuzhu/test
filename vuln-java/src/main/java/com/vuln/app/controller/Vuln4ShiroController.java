package com.vuln.app.controller;

import lombok.extern.slf4j.Slf4j;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.codec.Base64;
import org.apache.shiro.crypto.AesCipherService;
import org.apache.shiro.mgt.DefaultSecurityManager;
import org.apache.shiro.subject.Subject;
import org.apache.shiro.util.SimpleByteSource;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayInputStream;
import java.io.ObjectInputStream;

@Slf4j
@Controller
@RequestMapping("/vuln4")
public class Vuln4ShiroController {

    private static final String SHIRO_KEY = "kPH+bIxk5D2deZiIxcaaaA==";
    private final AesCipherService cipherService = new AesCipherService();

    static {
        DefaultSecurityManager securityManager = new DefaultSecurityManager();
        SecurityUtils.setSecurityManager(securityManager);
    }

    @GetMapping
    public String index(Model model) {
        model.addAttribute("vulnName", "Shiro反序列化漏洞");
        model.addAttribute("vulnDesc", "使用Apache Shiro 1.2.4的CVE-2016-4437漏洞");
        model.addAttribute("riskLevel", "高危");
        return "vuln4";
    }

    @PostMapping("/login")
    @ResponseBody
    public String login(@RequestParam String username, @RequestParam String password,
                       HttpServletResponse response) {
        try {
            Subject subject = SecurityUtils.getSubject();
            subject.login(new org.apache.shiro.authc.UsernamePasswordToken(username, password));

            byte[] serialized = serializeData(new UserData(username, System.currentTimeMillis()));
            byte[] encrypted = encryptData(serialized);

            Cookie rememberMeCookie = new Cookie("rememberMe", Base64.encodeToString(encrypted));
            rememberMeCookie.setHttpOnly(true);
            rememberMeCookie.setPath("/");
            response.addCookie(rememberMeCookie);

            return "登录成功！RememberMe cookie已设置";
        } catch (Exception e) {
            log.error("登录失败", e);
            return "登录失败: " + e.getMessage();
        }
    }

    @GetMapping("/check")
    @ResponseBody
    public String checkRememberMe(@CookieValue(value = "rememberMe", required = false) String rememberMe) {
        if (rememberMe != null) {
            try {
                byte[] encrypted = Base64.decode(rememberMe);
                byte[] decrypted = decryptData(encrypted);
                Object obj = deserializeData(decrypted);
                return "RememberMe验证成功！用户: " + obj.toString();
            } catch (Exception e) {
                log.error("RememberMe反序列化失败", e);
                return "RememberMe验证失败: " + e.getMessage();
            }
        }
        return "未检测到rememberMe cookie";
    }

    private byte[] serializeData(Object obj) throws Exception {
        java.io.ByteArrayOutputStream bos = new java.io.ByteArrayOutputStream();
        java.io.ObjectOutputStream oos = new java.io.ObjectOutputStream(bos);
        oos.writeObject(obj);
        oos.close();
        return bos.toByteArray();
    }

    private Object deserializeData(byte[] data) throws Exception {
        ByteArrayInputStream bis = new ByteArrayInputStream(data);
        ObjectInputStream ois = new ObjectInputStream(bis);
        return ois.readObject();
    }

    private byte[] encryptData(byte[] data) {
        return cipherService.encrypt(
            data,
            new SimpleByteSource(Base64.decode(SHIRO_KEY)).getBytes()
        ).getBytes();
    }

    private byte[] decryptData(byte[] encrypted) {
        return cipherService.decrypt(
            encrypted,
            new SimpleByteSource(Base64.decode(SHIRO_KEY)).getBytes()
        ).getBytes();
    }

    static class UserData implements java.io.Serializable {
        private String username;
        private long loginTime;

        public UserData(String username, long loginTime) {
            this.username = username;
            this.loginTime = loginTime;
        }

        @Override
        public String toString() {
            return "UserData{username='" + username + "', loginTime=" + loginTime + "}";
        }
    }
}
