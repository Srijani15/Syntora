package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import syntora.db.DBConnection;

public class SubjectDAO {
    public static List<Subject> getAllSubjects() {
        List<Subject> subjectList = new ArrayList<>();
        String sql = "SELECT id, name, department, year, semester, faculty_id, syllabus_image FROM subjects";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Subject subject = new Subject();
                subject.setId(rs.getInt("id"));
                subject.setName(rs.getString("name"));
                subject.setDepartment(rs.getString("department"));
                subject.setYear(rs.getInt("year"));
                subject.setSemester(rs.getInt("semester"));
                subject.setFacultyId(rs.getObject("faculty_id") != null ? rs.getInt("faculty_id") : null);
                subject.setSyllabusImage(rs.getString("syllabus_image"));
                subjectList.add(subject);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return subjectList;
    }
}