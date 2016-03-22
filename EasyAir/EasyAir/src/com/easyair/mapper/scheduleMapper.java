package com.easyair.mapper;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

import com.easyair.controller.ScheduleManager;
import com.easyair.dto.ScheduleDto;
import com.easyair.model.beans.FlightDataBean;
import com.easyair.model.beans.ScheduleDataBean;

public class scheduleMapper {

	/**
	 * 
	 * @param source
	 * @param destination
	 * @return
	 */
	public List<ScheduleDto> getScheduleDtoList(String source, String destination, Date departureDate) {
		List<ScheduleDto> schedules = new ArrayList<ScheduleDto>();
		ScheduleManager manager = new ScheduleManager();
		
	    List<FlightDataBean> flights = manager.getFlights(source, destination);
		
		for (FlightDataBean flight : flights) {
			
			Set<ScheduleDataBean> schedulesSet = manager.getFlightSchedules(flight.getFlightId());
			
			for (ScheduleDataBean schedule : schedulesSet) {
				if (departureDate.equals(schedule.getDepartureDate())) {
					ScheduleDto dto = new ScheduleDto();
					dto.setDestination(manager.getAirport(destination));
					dto.setSource(manager.getAirport(source));
					dto.setFlightId(flight.getFlightId());
					dto.setPrice(schedule.getPrice());
					dto.setScheduleId(schedule.getScheduleId());
					dto.setTripHours(schedule.getTripHours());
					Long airlineId = flight.getAirline().getAirlineId();
					dto.setAirlineId(airlineId);
					dto.setAirlineName(manager.getAirlineName(airlineId));
					schedules.add(dto);
				}
			}
		}
		
		return schedules;
	}
}
