package com.easyair.view.actions;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONArray;

import com.easyair.controller.AutocompleteManager;


public class AjaxAirportRequest extends HttpServlet {
   
    private static final long serialVersionUID = 1L;

    public AjaxAirportRequest() {
        super();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
       
        PrintWriter out = response.getWriter();
        response.setContentType("text/html");
        response.setHeader("Cache-control", "no-cache, no-store");
        response.setHeader("Pragma", "no-cache");
        response.setHeader("Expires", "-1");
       
        JSONArray arrayObj = new JSONArray();
        
        String query = request.getParameter("term");
        AutocompleteManager mgr = new AutocompleteManager();
        List<String> airports = mgr.getAirports(query);
       
        query = query.toLowerCase();
        for(String airport : airports) {
                arrayObj.put(airport);
        }
       
        out.println(arrayObj.toString());
        out.close();
       
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //Do something       
    }

}
