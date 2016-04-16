/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
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
@Table(name = "baggage")
public class BaggageDataBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long baggageId;
	/** */
	private String size;
	/** */
	private String weight;
	/** */
	private String type;
	/** */
	private UserBean user;
	/** */
	private TicketDataBean ticket;
	
	/**
	 * 
	 * @param size
	 * @param weight
	 * @param type
	 */
	public BaggageDataBean(String size, String weight, String type) {
		this.size = size;
		this.weight = weight;
		this.type = type;
	}
	
	/**
	 * @return the baggageId
	 */
	@Id
	@GeneratedValue
	@Column(name = "baggage_id")
	public Long getBaggageId() {
		return baggageId;
	}
	/**
	 * @param baggageId the baggageId to set
	 */
	public void setBaggageId(Long baggageId) {
		this.baggageId = baggageId;
	}
	/**
	 * @return the size
	 */
	@Column(name = "size", nullable = false)
	public String getSize() {
		return size;
	}
	/**
	 * @return the weight
	 */
	@Column(name = "weight", nullable = false)
	public String getWeight() {
		return weight;
	}
	/**
	 * @param weight the weight to set
	 */
	public void setWeight(String weight) {
		this.weight = weight;
	}
	/**
	 * @param size the size to set
	 */
	public void setSize(String size) {
		this.size = size;
	}
	/**
	 * @return the type
	 */
	@Column(name = "type")
	@Enumerated(EnumType.STRING)
	public String getType() {
		return type;
	}
	/**
	 * @param type the type to set
	 */
	public void setType(String type) {
		this.type = type;
	}
	/**
	 * @return the user
	 */
	@JoinColumn(name = "user_id")
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	public UserBean getUser() {
		return user;
	}
	/**
	 * @param user the user to set
	 */
	public void setUser(UserBean user) {
		this.user = user;
	}
	/**
	 * @return the ticket
	 */
	@JoinColumn(name = "ticket_id")
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	public TicketDataBean getTicket() {
		return ticket;
	}
	/**
	 * @param ticket the ticket to set
	 */
	public void setTicket(TicketDataBean ticket) {
		this.ticket = ticket;
	}
}
