package com.easyair.view.actions;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.struts2.interceptor.SessionAware;

import com.easyair.controller.LoginManager;
import com.easyair.model.beans.UserBean;
import com.easyair.utils.Constants;
import com.opensymphony.xwork2.ActionSupport;

public class LoginAction extends ActionSupport implements SessionAware {
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
	/** users */
	private List<UserBean> users = new ArrayList<>();
	/** session map for user */
	private Map<String, Object> sessionMap;

	/**
	 * 
	 */
	public LoginAction() {
		loginManager = new LoginManager();
	}

	/**
	 * 
	 * @return
	 */
	public String init() {
		return "login";
	}
	/**
	 * Method to authenticate the login
	 * 
	 * @return success when user authenticated
	 */
	public String authenticate() {
		UserBean user = loginManager.getUser(this.username, this.password);

		if (user != null) {
			sessionMap.put(Constants.USER, user);
			if (sessionMap.get(Constants.BOOK_FORWARD) != null) {
				return "book";
			}
			return "success";
		} else {
			addActionError(getText("error.login"));
			return "error";
		}
	}
	
	public String logout() {
		if (sessionMap.get(Constants.USER) != null) {
			sessionMap.remove(Constants.USER);
			sessionMap.remove(Constants.BOOK_FORWARD);
		} else {
			addActionError(getText("error.logout"));
		}
		return "success";
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

	@Override
	/**
	 * set session map
	 */
	public void setSession(Map sessionMap) {
		this.sessionMap = sessionMap;
	}
}
