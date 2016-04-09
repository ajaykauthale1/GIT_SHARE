/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Date;

import org.hibernate.Query;
import org.hibernate.classic.Session;

import com.easyair.model.beans.OrderDataBean;
import com.easyair.model.beans.PaymentDataBean;
import com.easyair.model.beans.TicketDataBean;
import com.easyair.utils.HibernateUtil;

/**
 * @author Ajay
 *
 */
public class PaymentManager extends HibernateUtil {

	/**
	 * 
	 * @param bean
	 */
	public void storePaymentInfo(PaymentDataBean bean) {
		bean = getPaymentInfo(bean.getCardNumber());
		if (bean == null) {
			HibernateUtil.persist(bean);
		}
	}

	/**
	 * 
	 * @param bean
	 */
	public void storeTicketInfo(TicketDataBean bean) {
		bean.setPnrNumber(getPNR(bean));
		bean.setTicketNumber(getPNR(bean));
		bean.setTicketId(getTicketId());
		// TODO need to change
		bean.setSeatNo("12B");
		HibernateUtil.persist(bean);
		storeOrder(bean);
	}

	/**
	 * 
	 * @param bean
	 */
	public void storeOrder(TicketDataBean bean) {
		OrderDataBean order = new OrderDataBean();
		order.setLastUpdatedOn(new Date());
		order.setOrderNumber(bean.getPnrNumber());
		order.setTicket(bean.getTicketId());
		order.setOrderId(getOrderId());
		HibernateUtil.persist(order);
	}

	/**
	 * 
	 * @param ticket
	 * @return
	 * @throws SQLException
	 */
	public String getPNR(TicketDataBean ticket) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		String appender = "001";
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select max(ticket_id) from ticket");

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				int max = rs.getInt(1);
				if (max != 0) {
					max++;
					appender = "00" + max;
				}
			}

			/*
			 * stmt = con.prepareStatement(
			 * "select a.name from schedule s, flight f, airline a where " +
			 * " s.flight_id = f.flight_id" + " and f.airline_id = a.airline_id"
			 * + " and s.schedule_id = ?"); stmt.setLong(1,
			 * ticket.getSchedule().getScheduleId()); rs = stmt.executeQuery();
			 * if (rs.next()) { String airline = rs.getString(1); appender =
			 * airline + appender; }
			 */
			appender = "CICPK";

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}

		return appender;
	}

	/**
	 * 
	 * @return
	 */
	public Long getTicketId() {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		Long id = new Long(1);
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select max(ticket_id) from ticket");

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				Long max = rs.getLong(1);
				if (max != 0) {
					id = max + 1;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}

		return id;
	}

	/**
	 * 
	 * @return
	 */
	public Long getOrderId() {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		Long id = new Long(1);
		session.beginTransaction();
		Connection con = session.connection();
		try {
			PreparedStatement stmt = con.prepareStatement("select max(order_id) from orders");

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				Long max = rs.getLong(1);
				if (max != 0) {
					id = max + 1;
				}
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}

		return id;
	}

	/**
	 * 
	 * @param userId
	 * @return
	 */
	public PaymentDataBean getPaymentInfo(Long userId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		PaymentDataBean payment = null;
		session.beginTransaction();
		try {
			String queryString = "from PaymentDataBean where user.userId = :id";
			Query query = session.createQuery(queryString);
			query.setLong("id", userId);
			payment = (PaymentDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return payment;
	}

	/**
	 * 
	 * @param cardNumber
	 * @return
	 */
	public PaymentDataBean getPaymentInfo(String cardNumber) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		PaymentDataBean payment = null;
		session.beginTransaction();
		try {
			String queryString = "from PaymentDataBean where cardNumber = :cardNumber";
			Query query = session.createQuery(queryString);
			query.setString("cardNumber", cardNumber);
			payment = (PaymentDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return payment;
	}

	/**
	 * 
	 * @param userId
	 * @param scheduleId
	 * @return
	 */
	public TicketDataBean getTicket(Long userId, Long scheduleId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		TicketDataBean ticket = null;
		session.beginTransaction();
		try {
			String queryString = "from TicketDataBean where user.userId = :userId and "
					+ "schedule.scheduleId = :scheduleId";
			Query query = session.createQuery(queryString);
			query.setLong("userId", userId);
			query.setLong("scheduleId", scheduleId);
			ticket = (TicketDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return ticket;
	}
}
