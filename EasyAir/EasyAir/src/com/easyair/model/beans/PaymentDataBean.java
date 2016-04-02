/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;

/**
 * @author Ajay
 *
 */
@Entity
@Table(name = "paymentInfo")
public class PaymentDataBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long payementId;
	/** */
	private String cardNumber;
	/** */
	private String expiryMonth;
	/** */
	private String expiryYear;
	/** */
	private String country;
	/** */
	private String address;
	/** */
	private String city;
	/** */
	private String state;
	/** */
	private String zipcode;
	/** */
	private UserBean user;
	/**
	 * @return the payementId
	 */
	@Id
	@GeneratedValue
	@Column(name = "payment_id")
	public Long getPayementId() {
		return payementId;
	}
	/**
	 * @param payementId the payementId to set
	 */
	public void setPayementId(Long payementId) {
		this.payementId = payementId;
	}
	/**
	 * @return the cardNumber
	 */
	@Column(name = "card_number", nullable=false, unique=true)
	public String getCardNumber() {
		return cardNumber;
	}
	/**
	 * @param cardNumber the cardNumber to set
	 */
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}
	/**
	 * @return the expiryMonth
	 */
	@Column(name = "card_expiry_month", nullable=false)
	public String getExpiryMonth() {
		return expiryMonth;
	}
	/**
	 * @param expiryMonth the expiryMonth to set
	 */
	public void setExpiryMonth(String expiryMonth) {
		this.expiryMonth = expiryMonth;
	}
	/**
	 * @return the expiryYear
	 */
	@Column(name = "card_expiry_year", nullable=false)
	public String getExpiryYear() {
		return expiryYear;
	}
	/**
	 * @param expiryYear the expiryYear to set
	 */
	public void setExpiryYear(String expiryYear) {
		this.expiryYear = expiryYear;
	}
	/**
	 * @return the country
	 */
	@Column(name = "country", nullable=false)
	public String getCountry() {
		return country;
	}
	/**
	 * @param country the country to set
	 */
	public void setCountry(String country) {
		this.country = country;
	}
	/**
	 * @return the address
	 */
	@Column(name = "billing_address", nullable=false)
	public String getAddress() {
		return address;
	}
	/**
	 * @param address the address to set
	 */
	public void setAddress(String address) {
		this.address = address;
	}
	/**
	 * @return the city
	 */
	@Column(name = "city", nullable=false)
	public String getCity() {
		return city;
	}
	/**
	 * @param city the city to set
	 */
	public void setCity(String city) {
		this.city = city;
	}
	/**
	 * @return the state
	 */
	@Column(name = "state", nullable=false)
	public String getState() {
		return state;
	}
	/**
	 * @param state the state to set
	 */
	public void setState(String state) {
		this.state = state;
	}
	/**
	 * @return the zipcode
	 */
	@Column(name = "zip_code", nullable=false)
	public String getZipcode() {
		return zipcode;
	}
	/**
	 * @param zipcode the zipcode to set
	 */
	public void setZipcode(String zipcode) {
		this.zipcode = zipcode;
	}
	/**
	 * @return the user
	 */
	@JoinColumn(name = "user_id")
    @ManyToOne(cascade = CascadeType.ALL,fetch = FetchType.LAZY)
	public UserBean getUser() {
		return user;
	}
	/**
	 * @param user the user to set
	 */
	public void setUser(UserBean user) {
		this.user = user;
	}
}
