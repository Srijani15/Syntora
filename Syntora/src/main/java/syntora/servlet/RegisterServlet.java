package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import syntora.db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirm_password");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String department = request.getParameter("department");
        String rollNumber = request.getParameter("roll_number");

        // Validate password match
        if (!password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=true&message=Passwords do not match");
            return;
        }

        int year = 1;
        int semester = 1;
        if ("student".equals(role)) {
            try {
                String yearParam = request.getParameter("year");
                String semesterParam = request.getParameter("semester");
                if (yearParam != null && !yearParam.trim().isEmpty()) year = Integer.parseInt(yearParam);
                if (semesterParam != null && !semesterParam.trim().isEmpty()) semester = Integer.parseInt(semesterParam);
            } catch (NumberFormatException e) {
                response.sendRedirect("register.jsp?error=true&message=Invalid year or semester");
                return;
            }
        }

        try (Connection conn = DBConnection.getConnection()) {
            // Check if username or email already exists
            String checkSql = "SELECT COUNT(*) FROM users WHERE username = ? OR email = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setString(1, username);
            checkPs.setString(2, email);
            ResultSet rs = checkPs.executeQuery();
            rs.next();
            if (rs.getInt(1) > 0) {
                response.sendRedirect("register.jsp?error=true&message=Username or email already exists");
                return;
            }

            // Insert into users table
            String userSql = "INSERT INTO users (username, email, password, role, department, year, semester) VALUES (?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement userPs = conn.prepareStatement(userSql, PreparedStatement.RETURN_GENERATED_KEYS);
            userPs.setString(1, username);
            userPs.setString(2, email);
            userPs.setString(3, password);
            userPs.setString(4, role);
            userPs.setString(5, department);
            if ("student".equals(role)) {
                userPs.setInt(6, year);
                userPs.setInt(7, semester);
            } else {
                userPs.setNull(6, java.sql.Types.INTEGER);
                userPs.setNull(7, java.sql.Types.INTEGER);
            }
            int userRows = userPs.executeUpdate();

            if (userRows > 0) {
                // Get the generated user ID
                ResultSet generatedKeys = userPs.getGeneratedKeys();
                int userId = -1;
                if (generatedKeys.next()) {
                    userId = generatedKeys.getInt(1);
                }

                if ("student".equals(role)) {
                    String studentSql = "INSERT INTO students (user_id, roll_number, first_name, last_name, dob, address) " +
                                        "VALUES (?, ?, ?, ?, ?, ?)";
                    PreparedStatement studentPs = conn.prepareStatement(studentSql);
                    studentPs.setInt(1, userId);
                    studentPs.setString(2, rollNumber);
                    studentPs.setString(3, firstName);
                    studentPs.setString(4, lastName);
                    studentPs.setDate(5, java.sql.Date.valueOf(dob));
                    studentPs.setString(6, address);
                    studentPs.executeUpdate();
                } else if ("faculty".equals(role)) {
                    String facultySql = "INSERT INTO faculty (user_id, first_name, last_name) " +
                                        "VALUES (?, ?, ?)";
                    PreparedStatement facultyPs = conn.prepareStatement(facultySql);
                    facultyPs.setInt(1, userId);
                    facultyPs.setString(2, firstName);
                    facultyPs.setString(3, lastName);
                    facultyPs.executeUpdate();
                }
                response.sendRedirect("login.jsp?success=true");
            } else {
                response.sendRedirect("register.jsp?error=true&message=Failed to register user");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=true&message=Server error");
        }
    }
}