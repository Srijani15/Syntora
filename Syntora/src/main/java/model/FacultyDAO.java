package model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;
import syntora.db.DBConnection;

public class FacultyDAO {
    public static List<Faculty> getAllFaculty() {
        List<Faculty> facultyList = new ArrayList<>();
        String sql = "SELECT id, user_id, title, first_name, last_name FROM faculty";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            
            while (rs.next()) {
                Faculty faculty = new Faculty();
                faculty.setId(rs.getInt("id"));
                faculty.setUserId(rs.getInt("user_id"));
                faculty.setTitle(rs.getString("title"));
                faculty.setFirstName(rs.getString("first_name"));
                faculty.setLastName(rs.getString("last_name"));
                facultyList.add(faculty);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return facultyList;
    }
}