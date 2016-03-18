package com.easyair.model.beans;

import java.io.Serializable;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.Table;

@Entity
@Table(name = "user")
public class UserBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/** user id */
	private Long userId;
	/** user first name */
	private String firstname;
	/** user last name */
	private String lastname;
	/** user email */
	private String email;
	/** notification flag */
	private boolean emailNotify;
	/** admin flag */
	private boolean isAdmin;

	/**
	 * @return the userId
	 */
	@Id
	@GeneratedValue
	@Column(name = "user_id")
	public Long getUserId() {
		return userId;
	}

	/**
	 * @param userId
	 *            the userId to set
	 */
	public void setUserId(Long userId) {
		this.userId = userId;
	}

	/**
	 * @return the firstname
	 */
	@Column(name = "first_name", nullable = false)
	public String getFirstname() {
		return firstname;
	}

	/**
	 * @param firstname
	 *            the firstname to set
	 */
	public void setFirstname(String firstname) {
		this.firstname = firstname;
	}

	/**
	 * @return the lastname
	 */
	@Column(name = "last_name", nullable = false)
	public String getLastname() {
		return lastname;
	}

	/**
	 * @param lastname
	 *            the lastname to set
	 */
	public void setLastname(String lastname) {
		this.lastname = lastname;
	}

	/**
	 * @return the email
	 */
	@Column(name = "email", unique = true, nullable = false)
	public String getEmail() {
		return email;
	}

	/**
	 * @param email
	 *            the email to set
	 */
	public void setEmail(String email) {
		this.email = email;
	}

	/**
	 * @return the emailNotify
	 */
	@Column(name = "email_notify")
	public boolean isEmailNotify() {
		return emailNotify;
	}

	/**
	 * @param emailNotify
	 *            the emailNotify to set
	 */
	public void setEmailNotify(boolean emailNotify) {
		this.emailNotify = emailNotify;
	}

	/**
	 * @return the isAdmin
	 */
	@Column(name = "is_admin")
	public boolean isAdmin() {
		return isAdmin;
	}

	/**
	 * @param isAdmin
	 *            the isAdmin to set
	 */
	public void setAdmin(boolean isAdmin) {
		this.isAdmin = isAdmin;
	}
}
