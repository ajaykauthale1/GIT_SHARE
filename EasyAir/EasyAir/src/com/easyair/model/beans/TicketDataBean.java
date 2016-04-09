/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;
import java.util.Date;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.EnumType;
import javax.persistence.Enumerated;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Temporal;
import javax.persistence.TemporalType;

/**
 * @author Ajay
 *
 */
@Entity
@Table(name = "ticket")
public class TicketDataBean implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long ticketId;
	/** */
	private String ticketNumber;
	/** */
	private String pnrNumber;
	/** */
	private double price;
	/** */
	private String chosenClass;
	/** */
	private Date boardingTime;
	/** */
	private UserBean user;
	/** */
	private ScheduleDataBean schedule;
	/** */
	private String seatNo;
	
	/**
	 * @return the ticketId
	 */
	@Id
	@GeneratedValue(strategy = GenerationType.IDENTITY)
	@Column(name = "ticket_id")
	public Long getTicketId() {
		return ticketId;
	}

	/**
	 * @param ticketId
	 *            the ticketId to set
	 */
	public void setTicketId(Long ticketId) {
		this.ticketId = ticketId;
	}

	/**
	 * @return the ticketNumber
	 */
	@Column(name = "ticket_number", unique = true, nullable = false)
	public String getTicketNumber() {
		return ticketNumber;
	}

	/**
	 * @param ticketNumber
	 *            the ticketNumber to set
	 */
	public void setTicketNumber(String ticketNumber) {
		this.ticketNumber = ticketNumber;
	}

	/**
	 * @return the pnrNumber
	 */
	@Column(name = "pnr_number", unique = true, nullable = false)
	public String getPnrNumber() {
		return pnrNumber;
	}

	/**
	 * @param pnrNumber
	 *            the pnrNumber to set
	 */
	public void setPnrNumber(String pnrNumber) {
		this.pnrNumber = pnrNumber;
	}

	/**
	 * @return the price
	 */
	@Column(name = "price", nullable = false)
	public double getPrice() {
		return price;
	}

	/**
	 * @param price
	 *            the price to set
	 */
	public void setPrice(double price) {
		this.price = price;
	}

	/**
	 * @return the chosenClass
	 */
	@Column(name = "class", nullable = false)
	@Enumerated(EnumType.STRING)
	public String getChosenClass() {
		return chosenClass;
	}

	/**
	 * @param chosenClass
	 *            the chosenClass to set
	 */
	public void setChosenClass(String chosenClass) {
		this.chosenClass = chosenClass;
	}

	/**
	 * @return the boardingTime
	 */
	@Temporal(TemporalType.DATE)
	@Column(name = "boarding_time")
	public Date getBoardingTime() {
		return boardingTime;
	}

	/**
	 * @param boardingTime
	 *            the boardingTime to set
	 */
	public void setBoardingTime(Date boardingTime) {
		this.boardingTime = boardingTime;
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
	 * @param user
	 *            the user to set
	 */
	public void setUser(UserBean user) {
		this.user = user;
	}

	/**
	 * @return the schedule
	 */
	@JoinColumn(name = "schedule_id")
	@ManyToOne(cascade = CascadeType.ALL, fetch = FetchType.LAZY)
	public ScheduleDataBean getSchedule() {
		return schedule;
	}

	/**
	 * @param schedule
	 *            the schedule to set
	 */
	public void setSchedule(ScheduleDataBean schedule) {
		this.schedule = schedule;
	}
	/**
	 * @return the seatNo
	 */
	@Column(name = "seat_no", nullable=true)
	public String getSeatNo() {
		return seatNo;
	}
	/**
	 * @param seatNo the seatNo to set
	 */
	public void setSeatNo(String seatNo) {
		this.seatNo = seatNo;
	}
}
