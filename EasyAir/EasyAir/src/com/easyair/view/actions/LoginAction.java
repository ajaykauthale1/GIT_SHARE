package com.easyair.view.actions;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang3.StringUtils;

import com.easyair.controller.LoginManager;
import com.easyair.model.beans.UserBean;
import com.opensymphony.xwork2.ActionSupport;

public class LoginAction extends ActionSupport {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** User name */
	private String username;
	/** Password */
	private String password;
	/** Manager for database access */
	private LoginManager loginManager;
	private List<UserBean> users = new ArrayList<>();
	
	/**
	 * 
	 */
	public LoginAction() {
		loginManager = new LoginManager();
	}

	/**
	 * Method to authenticate the login
	 * 
	 * @return success when user authenticated
	 */
	public String authenticate() {
		System.out.println("started...");
		
		boolean isFound = loginManager.authenticate(this.username, this.password);
		
		if (isFound) {
			return "success";
		} else {
			addActionError(getText("error.login"));
			return "error";
		}
	}

	public String execute() {
		return authenticate();
	}

	/**
	 * @return the username
	 */
	public String getUsername() {
		return username;
	}

	/**
	 * @param username
	 *            the username to set
	 */
	public void setUsername(String username) {
		this.username = username;
	}

	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}

	/**
	 * @param password
	 *            the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}

}
