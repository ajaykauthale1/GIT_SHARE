/**
 * 
 */
package com.easyair.dto;

/**
 * @author Ajay
 *
 */
public class ScheduleDto {
	private Long scheduleId;
	private Long flightId;
	private Long airlineId;
	private String airlineName;
	private String source;
	private String destination;
	private double tripHours;
	private double price;
	/**
	 * @return the scheduleId
	 */
	public Long getScheduleId() {
		return scheduleId;
	}
	/**
	 * @param scheduleId the scheduleId to set
	 */
	public void setScheduleId(Long scheduleId) {
		this.scheduleId = scheduleId;
	}
	/**
	 * @return the flightId
	 */
	public Long getFlightId() {
		return flightId;
	}
	/**
	 * @param flightId the flightId to set
	 */
	public void setFlightId(Long flightId) {
		this.flightId = flightId;
	}
	/**
	 * @return the airlineId
	 */
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
	 * @return the airlineName
	 */
	public String getAirlineName() {
		return airlineName;
	}
	/**
	 * @param airlineName the airlineName to set
	 */
	public void setAirlineName(String airlineName) {
		this.airlineName = airlineName;
	}
	/**
	 * @return the source
	 */
	public String getSource() {
		return source;
	}
	/**
	 * @param source the source to set
	 */
	public void setSource(String source) {
		this.source = source;
	}
	/**
	 * @return the destination
	 */
	public String getDestination() {
		return destination;
	}
	/**
	 * @param destination the destination to set
	 */
	public void setDestination(String destination) {
		this.destination = destination;
	}
	/**
	 * @return the tripHours
	 */
	public double getTripHours() {
		return tripHours;
	}
	/**
	 * @param tripHours the tripHours to set
	 */
	public void setTripHours(double tripHours) {
		this.tripHours = tripHours;
	}
	/**
	 * @return the price
	 */
	public double getPrice() {
		return price;
	}
	/**
	 * @param price the price to set
	 */
	public void setPrice(double price) {
		this.price = price;
	}
}
