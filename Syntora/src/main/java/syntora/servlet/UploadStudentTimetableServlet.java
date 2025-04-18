package syntora.servlet;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
//import java.sql.ResultSet;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;

import syntora.db.DBConnection;

@WebServlet("/UploadStudentTimetableServlet")
@SuppressWarnings("serial")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class UploadStudentTimetableServlet extends HttpServlet {
    private static final String UPLOAD_DIR = "uploads/timetables";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String department = request.getParameter("department");
        String yearStr = request.getParameter("year");
        String semesterStr = request.getParameter("semester");
        Part filePart = request.getPart("timetableImage");

        if (department == null || yearStr == null || semesterStr == null || filePart == null) {
            response.sendRedirect("pages/editStudentTimetable.jsp?status=error&message=Missing+parameters");
            return;
        }

        int year = Integer.parseInt(yearStr);
        int semester = Integer.parseInt(semesterStr);
        String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
        String fileExtension = fileName.substring(fileName.lastIndexOf("."));
        String storedFileName = department + "_" + year + "_" + semester + "_" + System.currentTimeMillis() + fileExtension;
        String uploadPath = getServletContext().getRealPath("") + UPLOAD_DIR;

        // Create upload directory if it doesn't exist
        Files.createDirectories(Paths.get(uploadPath));

        // Save the file
        try (InputStream input = filePart.getInputStream()) {
            Files.copy(input, Paths.get(uploadPath, storedFileName), StandardCopyOption.REPLACE_EXISTING);
        }

        // Store timetable metadata in the database
        try (Connection conn = DBConnection.getConnection()) {
            String sql = "INSERT INTO timetable (department, year, semester, image_path) VALUES (?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, department);
            ps.setInt(2, year);
            ps.setInt(3, semester);
            ps.setString(4, UPLOAD_DIR + "/" + storedFileName);
            ps.executeUpdate();

            response.sendRedirect("pages/adminManageTimetable.jsp?status=success");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect("pages/editStudentTimetable.jsp?status=error&message=Database+error");
        }
    }
}