package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import syntora.db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/AdminUpdateServlet")
@SuppressWarnings("serial")
public class AdminUpdateServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String role = request.getParameter("role");
        int id = Integer.parseInt(request.getParameter("id"));
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String department = request.getParameter("department");

        try (Connection conn = DBConnection.getConnection()) {
            String sql;
            PreparedStatement ps;
            if ("student".equals(role)) {
                String rollNumber = request.getParameter("roll_number");
                int year = Integer.parseInt(request.getParameter("year"));
                int semester = Integer.parseInt(request.getParameter("semester"));
                sql = "UPDATE students SET username=?, email=?, first_name=?, last_name=?, dob=?, address=?, roll_number=?, year=?, semester=?, department=? WHERE id=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setDate(5, java.sql.Date.valueOf(dob));
                ps.setString(6, address);
                ps.setString(7, rollNumber);
                ps.setInt(8, year);
                ps.setInt(9, semester);
                ps.setString(10, department);
                ps.setInt(11, id);
            } else {
                sql = "UPDATE faculty SET username=?, email=?, first_name=?, last_name=?, dob=?, address=?, department=? WHERE id=?";
                ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setDate(5, java.sql.Date.valueOf(dob));
                ps.setString(6, address);
                ps.setString(7, department);
                ps.setInt(8, id);
            }
            ps.executeUpdate();
            response.sendRedirect("admin" + (role.equals("student") ? "Students" : "Faculty"));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=true");
        }
    }
}