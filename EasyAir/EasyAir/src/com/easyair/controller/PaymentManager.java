/**
 * 
 */
package com.easyair.controller;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Set;

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
		PaymentDataBean payment = getPaymentInfo(bean.getCardNumber());
		if (payment == null) {
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
		bean.setSeatNo(getTicketId() + "B");
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
	 */
	public String cancelOrder(Long orderId) {
		OrderDataBean order = getOrder(orderId);
		TicketDataBean ticket = getTicket(order.getTicket());
		order.setCancelled(true);
		HibernateUtil.update(order);
		ticket.setDeleted(true);
		HibernateUtil.update(ticket);
		return "success";
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

			appender = "CICPK" + appender;

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
		Session session1 = HibernateUtil.getSessionFactory().getCurrentSession();
		Long id = new Long(1);
		session1.beginTransaction();
		Connection con = session1.connection();
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
			session1.getTransaction().rollback();
		} finally {
			session1.getTransaction().commit();
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
			Connection con = session.connection();
			PreparedStatement stmt = con.prepareStatement("select max(ticket_id) from ticket");
			ResultSet rs = stmt.executeQuery();
			Long ticketId = null;
			if (rs.next()) {
				ticketId = rs.getLong(1);
			}

			String queryString = "from TicketDataBean where user.userId = :userId and "
					+ "schedule.scheduleId = :scheduleId and deleted = :deleted ";
			if (ticketId != null) {
				queryString = queryString + " and ticketId =:ticketId";
			}
			Query query = session.createQuery(queryString);
			query.setLong("userId", userId);
			query.setLong("scheduleId", scheduleId);
			query.setBoolean("deleted", false);
			if (ticketId != null) {
				query.setLong("ticketId", ticketId);
			}
			ticket = (TicketDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return ticket;
	}

	/**
	 * 
	 * @param ticketId
	 * @return
	 */
	public TicketDataBean getTicket(Long ticketId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		TicketDataBean ticket = null;
		session.beginTransaction();
		try {
			String queryString = "from TicketDataBean where ticketId = :ticketId";
			Query query = session.createQuery(queryString);
			query.setLong("ticketId", ticketId);
			ticket = (TicketDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return ticket;
	}

	/**
	 * 
	 * @param orderId
	 * @return
	 */
	public OrderDataBean getOrder(Long orderId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		OrderDataBean order = null;
		session.beginTransaction();
		try {
			String queryString = "from OrderDataBean where orderId = :orderId";
			Query query = session.createQuery(queryString);
			query.setLong("orderId", orderId);
			order = (OrderDataBean) query.uniqueResult();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return order;
	}

	/**
	 * 
	 * @param userId
	 * @return
	 */
	public List<TicketDataBean> getTickets(Long userId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		List<TicketDataBean> tickets = null;
		session.beginTransaction();
		try {
			String queryString = "from TicketDataBean where user.userId = :userId";
			Query query = session.createQuery(queryString);
			query.setLong("userId", userId);
			tickets = (List<TicketDataBean>) query.list();
		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		}
		session.getTransaction().commit();
		return tickets;
	}

	/**
	 * 
	 * @param userId
	 * @return
	 */
	public OrderDataBean getOrderForTicket(Long ticketId) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		OrderDataBean order = null;
		session.beginTransaction();
		Connection con = session.connection();
		try {
			String queryString = "select order_id, order_number, "
					+ "ticket_id, last_updated, is_cancelled from orders where ticket_id = ?";

			PreparedStatement stmt = con.prepareStatement(queryString);

			stmt.setLong(1, ticketId);

			ResultSet rs = stmt.executeQuery();
			if (rs.next()) {
				order = new OrderDataBean();
				order.setOrderId(rs.getLong(1));
				order.setOrderNumber(rs.getString(2));
				order.setTicket(rs.getLong(3));
				order.setLastUpdatedOn(rs.getDate(4));
				order.setCancelled(rs.getBoolean(5));
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}
		return order;
	}

	/**
	 * 
	 * @param tickets
	 * @return
	 */
	public List<OrderDataBean> getOrders(Set<Long> tickets) {
		Session session = HibernateUtil.getSessionFactory().getCurrentSession();
		Long id = new Long(1);
		List<OrderDataBean> orders = new ArrayList<OrderDataBean>();
		session.beginTransaction();
		Connection con = session.connection();
		try {
			String queryString = "select order_id, order_number, "
					+ "ticket_id, last_updated, is_cancelled from orders where ticket_id in (";

			for (Long ticketId : tickets) {
				queryString = queryString + "?, ";
			}

			queryString = queryString.substring(0, queryString.lastIndexOf(","));
			queryString = queryString + ")";

			PreparedStatement stmt = con.prepareStatement(queryString);

			int cnt = 1;
			for (Long ticketId : tickets) {
				stmt.setLong(cnt++, ticketId);
			}

			ResultSet rs = stmt.executeQuery();
			while (rs.next()) {
				OrderDataBean bean = new OrderDataBean();
				bean.setOrderId(rs.getLong(1));
				bean.setOrderNumber(rs.getString(2));
				bean.setTicket(rs.getLong(3));
				bean.setLastUpdatedOn(rs.getDate(4));
				bean.setCancelled(rs.getBoolean(5));
				orders.add(bean);
			}

		} catch (Exception e) {
			e.printStackTrace();
			session.getTransaction().rollback();
		} finally {
			session.getTransaction().commit();
		}
		return orders;
	}
}
