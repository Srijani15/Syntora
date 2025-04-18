package syntora.model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class FacultyDAO {
    public static List<Faculty> getAllFaculty() {
        List<Faculty> facultyList = new ArrayList<>();
        try {
            // Database connection logic
            DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/yourDatabase");
            Connection conn = ds.getConnection();
            String sql = "SELECT * FROM faculty";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Faculty faculty = new Faculty();
                faculty.setId(rs.getInt("id"));
                faculty.setTitle(rs.getString("title"));
                faculty.setFirstName(rs.getString("first_name"));
                faculty.setLastName(rs.getString("last_name"));
                facultyList.add(faculty);
            }
            rs.close();
            stmt.close();
            conn.close();
        } catch (SQLException | NamingException e) {
            e.printStackTrace();
        }
        return facultyList;
    }
}
