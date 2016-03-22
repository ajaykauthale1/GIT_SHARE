package com.easyair.model.beans;

import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
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
	/** date of birth */
	private Date dateOfBirth;
	/** date of birth */
	private String gender;
	/** Payment */
	private Set<PaymentDataBean> payment;

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

	/**
	 * @return the payment
	 */
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "user")
	public Set<PaymentDataBean> getPayment() {
		return payment;
	}

	/**
	 * @param payment the payment to set
	 */
	public void setPayment(Set<PaymentDataBean> payment) {
		this.payment = payment;
	}

	/**
	 * @return the dateOfBirth
	 */
	@Column(name="date_of_birth", nullable=false)
	public Date getDateOfBirth() {
		SimpleDateFormat sdf = new SimpleDateFormat("MM-dd-yyyy");
		try {
			dateOfBirth = sdf.parse(sdf.format(dateOfBirth));
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return dateOfBirth;
	}

	/**
	 * @param dateOfBirth the dateOfBirth to set
	 */
	public void setDateOfBirth(Date dateOfBirth) {
		this.dateOfBirth = dateOfBirth;
	}

	/**
	 * @return the gender
	 */
	@Column(name="gender", nullable=false)
	@Enumerated(EnumType.STRING)
	public String getGender() {
		return gender;
	}

	/**
	 * @param gender the gender to set
	 */
	public void setGender(String gender) {
		this.gender = gender;
	}
}
