package syntora.servlet;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import syntora.db.DBConnection;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/adminStudents")
@SuppressWarnings("serial")
public class AdminStudentServlet extends HttpServlet {

    public static class Student {
        private String rollNumber;
        private String firstName;
        private String lastName;
        private String department;
        private int year;
        private int semester;
        private String dob;
        private String address;

        public Student(String rollNumber, String firstName, String lastName, String department, int year, int semester, String dob, String address) {
            this.rollNumber = rollNumber;
            this.firstName = firstName;
            this.lastName = lastName;
            this.department = department;
            this.year = year;
            this.semester = semester;
            this.dob = dob;
            this.address = address;
        }

        public String getRollNumber() { return rollNumber; }
        public String getFirstName() { return firstName; }
        public String getLastName() { return lastName; }
        public String getDepartment() { return department; }
        public int getYear() { return year; }
        public int getSemester() { return semester; }
        public String getDob() { return dob; }
        public String getAddress() { return address; }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String department = request.getParameter("department");
        String yearStr = request.getParameter("year");

        System.out.println("AdminStudentServlet - Action: " + action + ", Department: " + department + ", Year: " + yearStr);

        if ("delete".equals(action)) {
            String rollNumber = request.getParameter("roll");
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "DELETE FROM students WHERE roll_number = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, rollNumber);
                ps.executeUpdate();

                sql = "DELETE FROM users WHERE username = (SELECT username FROM students WHERE roll_number = ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, rollNumber);
                ps.executeUpdate();
            } catch (Exception e) {
                e.printStackTrace();
            }
            response.sendRedirect("adminStudents?department=" + department + "&year=" + yearStr);
        } else if ("new".equals(action)) {
            response.sendRedirect("editStudent.jsp");
        } else {
            List<Student> students = new ArrayList<>();
            try (Connection conn = DBConnection.getConnection()) {
                String sql = "SELECT s.roll_number, s.first_name, s.last_name, u.department, u.year, u.semester, s.dob, s.address " +
                             "FROM students s JOIN users u ON s.user_id = u.id WHERE u.role = 'student' " +
                             (department != null && !department.isEmpty() ? "AND u.department = ?" : "") +
                             (yearStr != null && !yearStr.isEmpty() ? "AND u.year = ?" : "");
                PreparedStatement ps = conn.prepareStatement(sql);
                int paramIndex = 1;
                if (department != null && !department.isEmpty()) {
                    ps.setString(paramIndex++, department);
                }
                if (yearStr != null && !yearStr.isEmpty()) {
                    ps.setInt(paramIndex, Integer.parseInt(yearStr));
                }
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    students.add(new Student(
                        rs.getString("roll_number"),
                        rs.getString("first_name"),
                        rs.getString("last_name"),
                        rs.getString("department"),
                        rs.getInt("year"),
                        rs.getInt("semester"),
                        rs.getString("dob"),
                        rs.getString("address")
                    ));
                }
                System.out.println("Fetched " + students.size() + " students");
            } catch (Exception e) {
                e.printStackTrace();
            }
            request.setAttribute("students", students);
            request.getRequestDispatcher("/pages/adminManageStudents.jsp").forward(request, response);
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");
        String rollNumber = request.getParameter("rollNumber");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String firstName = request.getParameter("first_name");
        String lastName = request.getParameter("last_name");
        String dob = request.getParameter("dob");
        String address = request.getParameter("address");
        String department = request.getParameter("department");
        String yearStr = request.getParameter("year");
        String semesterStr = request.getParameter("semester");

        System.out.println("Updating student - Roll Number: " + rollNumber + ", Department: " + department + ", Year: " + yearStr);

        try (Connection conn = DBConnection.getConnection()) {
            if ("update".equals(action) && rollNumber != null) {
                // Update students table
                String sql = "UPDATE students SET username = ?, email = ?, first_name = ?, last_name = ?, dob = ?, address = ? WHERE roll_number = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, email);
                ps.setString(3, firstName);
                ps.setString(4, lastName);
                ps.setDate(5, java.sql.Date.valueOf(dob));
                ps.setString(6, address);
                ps.setString(7, rollNumber);
                int rowsAffected = ps.executeUpdate();
                System.out.println("Updated " + rowsAffected + " rows in students");

                // Update users table
                sql = "UPDATE users SET username = ?, department = ?, year = ?, semester = ? WHERE id = (SELECT user_id FROM students WHERE roll_number = ?)";
                ps = conn.prepareStatement(sql);
                ps.setString(1, username);
                ps.setString(2, department);
                ps.setInt(3, Integer.parseInt(yearStr));
                ps.setInt(4, Integer.parseInt(semesterStr));
                ps.setString(5, rollNumber);
                rowsAffected = ps.executeUpdate();
                System.out.println("Updated " + rowsAffected + " rows in users");
            } else {
                response.sendRedirect("register.jsp");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?status=error");
            return;
        }
        response.sendRedirect("adminStudents?department=" + department + "&year=" + yearStr);
    }
}