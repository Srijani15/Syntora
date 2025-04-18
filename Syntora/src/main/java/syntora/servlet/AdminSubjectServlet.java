package syntora.servlet;

import java.io.*;
import java.sql.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.annotation.*;
import javax.servlet.http.*;

import syntora.db.DBConnection;

@WebServlet("/adminSubjects")
@SuppressWarnings("serial")
@MultipartConfig(fileSizeThreshold = 1024 * 1024,    // 1MB
                 maxFileSize = 1024 * 1024 * 5,      // 5MB
                 maxRequestSize = 1024 * 1024 * 10)  // 10MB
public class AdminSubjectServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads/syllabus";

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String action = request.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                String sql = "DELETE FROM subjects WHERE id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setInt(1, id);
                ps.executeUpdate();
                response.sendRedirect("adminSubjects");
            } else {
                // Handle subject filtering
                String dept = request.getParameter("filterDept");
                String year = request.getParameter("filterYear");
                String sem = request.getParameter("filterSem");

                List<Object[]> subjects = new ArrayList<>();

                if (dept != null && year != null && sem != null &&
                    !dept.isEmpty() && !year.isEmpty() && !sem.isEmpty()) {

                    String sql = "SELECT s.id, s.name, s.department, s.year, s.semester, f.first_name, f.last_name, s.syllabus_image " +
                                 "FROM subjects s LEFT JOIN faculty f ON s.faculty_id = f.id " +
                                 "WHERE s.department = ? AND s.year = ? AND s.semester = ? ORDER BY s.name";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setString(1, dept);
                    ps.setInt(2, Integer.parseInt(year));
                    ps.setInt(3, Integer.parseInt(sem));
                    ResultSet rs = ps.executeQuery();

                    while (rs.next()) {
                        subjects.add(new Object[]{
                            rs.getInt("id"),
                            rs.getString("name"),
                            rs.getString("department"),
                            rs.getInt("year"),
                            rs.getInt("semester"),
                            rs.getString("first_name") + " " + rs.getString("last_name"),
                            rs.getString("syllabus_image")
                        });
                    }

                    request.setAttribute("selectedDept", dept);
                    request.setAttribute("selectedYear", year);
                    request.setAttribute("selectedSem", sem);
                    request.setAttribute("subjects", subjects);
                }

                request.getRequestDispatcher("/pages/adminManageSubjects.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminDashboard.jsp?error=true");
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            // Read multipart form data
            String name = request.getParameter("name");
            String department = request.getParameter("department");
            int year = Integer.parseInt(request.getParameter("year"));
            int semester = Integer.parseInt(request.getParameter("semester"));
            int facultyId = Integer.parseInt(request.getParameter("faculty_id"));
            Part filePart = request.getPart("syllabus_image");

            String fileName = extractFileName(filePart);
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String savedFileName = System.currentTimeMillis() + "_" + fileName;
            filePart.write(uploadPath + File.separator + savedFileName);

            try (Connection conn = DBConnection.getConnection()) {
                String sql = "INSERT INTO subjects (name, department, year, semester, faculty_id, syllabus_image) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, department);
                ps.setInt(3, year);
                ps.setInt(4, semester);
                ps.setInt(5, facultyId);
                ps.setString(6, savedFileName);
                ps.executeUpdate();
            }

            response.sendRedirect("adminSubjects");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("adminSubjects?error=true");
        }
    }

    private String extractFileName(Part part) {
        String content = part.getHeader("content-disposition");
        for (String s : content.split(";")) {
            if (s.trim().startsWith("filename")) {
                return new File(s.substring(s.indexOf('=') + 1).trim().replace("\"", "")).getName();
            }
        }
        return null;
    }
}
