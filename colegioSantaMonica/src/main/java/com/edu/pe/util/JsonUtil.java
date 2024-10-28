package com.edu.pe.util;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;

public class JsonUtil {

    private static final ObjectMapper objectMapper = new ObjectMapper();
    private static final Gson gson = new Gson();

 
    public static String toJsonValueAsString(Object object) {
        try {
            return objectMapper.writeValueAsString(object);
        } catch (Exception e) {
            e.printStackTrace();
            return "{}"; 
        }
    }

    public static String toJsonWithGson(Object object) {
        return gson.toJson(object);
    }
}