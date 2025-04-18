package model;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import javax.sql.DataSource;
import javax.naming.InitialContext;
import javax.naming.NamingException;

public class SubjectDAO {
    public static List<Subject> getAllSubjects() {
        List<Subject> subjectList = new ArrayList<>();
        try {
            // Database connection logic
            DataSource ds = (DataSource) new InitialContext().lookup("java:comp/env/jdbc/yourDatabase");
            Connection conn = ds.getConnection();
            String sql = "SELECT * FROM subjects";
            PreparedStatement stmt = conn.prepareStatement(sql);
            ResultSet rs = stmt.executeQuery();

            while (rs.next()) {
                Subject subject = new Subject();
                subject.setId(rs.getInt("id"));
                subject.setName(rs.getString("name"));
                subjectList.add(subject);
            }
            rs.close();
            stmt.close();
            conn.close();
        } catch (SQLException | NamingException e) {
            e.printStackTrace();
        }
        return subjectList;
    }
}
