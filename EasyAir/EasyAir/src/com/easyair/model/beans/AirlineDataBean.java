/**
 * 
 */
package com.easyair.model.beans;

import java.io.Serializable;
import java.util.HashSet;
import java.util.Set;

import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;
import javax.persistence.OneToMany;
import javax.persistence.Table;

/**
 * @author Ajay
 *
 */
@Entity
@Table(name = "airline")
public class AirlineDataBean implements Serializable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/** */
	private Long airlineId;
	/** */
	private String name;
	/** */
	private int noOfFlights;
	/** */
	private Set<FlightDataBean> flights = new HashSet<FlightDataBean>(0);
	
	/**
	 * @return the airlineId
	 */
	@Id
	@GeneratedValue
	@Column(name = "airline_id")
	public Long getAirlineId() {
		return airlineId;
	}
	/**
	 * @param airlineId the airlineId to set
	 */
	public void setAirlineId(Long airlineId) {
		this.airlineId = airlineId;
	}
	/**
	 * @return the name
	 */
	@Column(name = "name", nullable = false)
	public String getName() {
		return name;
	}
	/**
	 * @param name the name to set
	 */
	public void setName(String name) {
		this.name = name;
	}
	/**
	 * @return the noOfFlights
	 */
	@Column(name = "no_of_flights")
	public int getNoOfFlights() {
		return noOfFlights;
	}
	/**
	 * @param noOfFlights the noOfFlights to set
	 */
	public void setNoOfFlights(int noOfFlights) {
		this.noOfFlights = noOfFlights;
	}
	/**
	 * @return the flights
	 */
	@OneToMany(fetch = FetchType.LAZY, mappedBy = "airline")
	public Set<FlightDataBean> getFlights() {
		return flights;
	}
	/**
	 * @param flights the flights to set
	 */
	public void setFlights(Set<FlightDataBean> flights) {
		this.flights = flights;
	}
}
