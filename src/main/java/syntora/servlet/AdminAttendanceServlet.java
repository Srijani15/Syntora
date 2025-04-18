package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import syntora.db.DBConnection;

@WebServlet("/adminAttendance")
public class AdminAttendanceServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        int id = Integer.parseInt(request.getParameter("id"));
        String rollNumber = request.getParameter("rollNumber");
        String department = request.getParameter("department");
        String year = request.getParameter("year");
        String semester = request.getParameter("semester");

        try (Connection conn = DBConnection.getConnection()) {
            if ("edit".equals(action)) {
                String status = request.getParameter("status");
                if ("Present".equals(status) || "Absent".equals(status)) {
                    String sql = "UPDATE attendance SET status = ? WHERE id = ?";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, status);
                    ps.setInt(2, id);
                    ps.executeUpdate();
                    ps.close();
                } else {
                    throw new Exception("Invalid status value");
                }
            } else if ("delete".equals(action)) {
                String sql = "DELETE FROM attendance WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                ps.close();
            }
            // Redirect with parameters to preserve context
            response.sendRedirect(String.format("pages/adminManageAttendance.jsp?rollNumber=%s&department=%s&year=%s&semester=%s",
                    rollNumber, department, year, semester));
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(String.format("pages/adminManageAttendance.jsp?rollNumber=%s&department=%s&year=%s&semester=%s&error=true",
                    rollNumber, department, year, semester));
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Forward to JSP with parameters
        request.getRequestDispatcher("pages/adminManageAttendance.jsp").forward(request, response);
    }
}