/**
 * 
 */
package com.easyair.view.actions;

import java.util.Date;

import com.opensymphony.xwork2.ActionSupport;

/**
 * @author Ajay
 *
 */
public class SignupAction extends ActionSupport {
	/** */
	private String firstName;
	/** */
	private String lastName;
	/** */
	private String email;
	/** */
	private String password;
	/** */
	private String repeatPassword;
	/** */
	private boolean emailNotify;
	/** */
	private String gender;
	/** */
	private Date dateOfBirth;
	
	
	public String init() {
		return "success";
	}
	
	/**
	 * @return the firstName
	 */
	public String getFirstName() {
		return firstName;
	}
	/**
	 * @param firstName the firstName to set
	 */
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	/**
	 * @return the lastName
	 */
	public String getLastName() {
		return lastName;
	}
	/**
	 * @param lastName the lastName to set
	 */
	public void setLastName(String lastName) {
		this.lastName = lastName;
	}
	/**
	 * @return the email
	 */
	public String getEmail() {
		return email;
	}
	/**
	 * @param email the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}
	/**
	 * @return the password
	 */
	public String getPassword() {
		return password;
	}
	/**
	 * @param password the password to set
	 */
	public void setPassword(String password) {
		this.password = password;
	}
	/**
	 * @return the repeatPassword
	 */
	public String getRepeatPassword() {
		return repeatPassword;
	}
	/**
	 * @param repeatPassword the repeatPassword to set
	 */
	public void setRepeatPassword(String repeatPassword) {
		this.repeatPassword = repeatPassword;
	}
	/**
	 * @return the emailNotify
	 */
	public boolean isEmailNotify() {
		return emailNotify;
	}
	/**
	 * @param emailNotify the emailNotify to set
	 */
	public void setEmailNotify(boolean emailNotify) {
		this.emailNotify = emailNotify;
	}
	/**
	 * @return the gender
	 */
	public String getGender() {
		return gender;
	}
	/**
	 * @param gender the gender to set
	 */
	public void setGender(String gender) {
		this.gender = gender;
	}
	/**
	 * @return the dateOfBirth
	 */
	public Date getDateOfBirth() {
		return dateOfBirth;
	}
	/**
	 * @param dateOfBirth the dateOfBirth to set
	 */
	public void setDateOfBirth(Date dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}
}
