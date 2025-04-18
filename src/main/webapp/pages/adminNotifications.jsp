<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, javax.servlet.*, javax.servlet.http.*" %>
<%
    String username = (String) session.getAttribute("username");
    String userType = (String) session.getAttribute("userType");
    if (username == null || !"admin".equals(userType)) {
        response.sendRedirect("../login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Admin Notifications - Syntora</title>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://bootswatch.com/5/flatly/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
</head>
<body>
    <button class="toggle-btn d-md-none"><i class="fas fa-bars"></i></button>
    <div class="sidebar">
        <h3><i class="fas fa-school"></i> Syntora Admin</h3>
        <a href="${pageContext.request.contextPath}/pages/adminDashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a>
        <a href="#" class="active"><i class="fas fa-bell"></i> Notifications</a>
        <a href="${pageContext.request.contextPath}/logout"><i class="fas fa-sign-out-alt"></i> Logout</a>
    </div>

    <div class="content">
        <h2 class="mb-4">Notifications</h2>

        <ul class="nav nav-tabs mb-3" id="notificationTabs">
            <li class="nav-item">
                <a class="nav-link active" href="#sendTab" data-bs-toggle="tab">Send Notification</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#sentTab" data-bs-toggle="tab">Sent Notifications</a>
            </li>
            <li class="nav-item">
                <a class="nav-link" href="#receivedTab" data-bs-toggle="tab">Received Notifications</a>
            </li>
        </ul>

        <div class="tab-content">
            <!-- SEND TAB -->
            <div class="tab-pane fade show active" id="sendTab">
                <form action="${pageContext.request.contextPath}/SendNotificationServlet" method="post" class="card p-4 shadow-sm">
                    <input type="hidden" name="senderId" value="<%= session.getAttribute("userId") %>">
                    <input type="hidden" name="senderType" value="admin">

                    <div class="form-group mb-3">
                        <label for="recipientType">Recipient Type</label>
                        <select name="recipientType" id="recipientType" class="form-control" required>
                            <option value="">Select</option>
                            <option value="student">Student</option>
                            <option value="faculty">Faculty</option>
                        </select>
                    </div>

                    <div class="form-group mb-3">
                        <label for="department">Department</label>
                        <select name="department" id="department" class="form-control" required>
                            <option value="">Select Department</option>
                            <option value="CSE">CSE</option>
                            <option value="IT">IT</option>
                            <option value="AIML">AIML</option>
                            <option value="ECE">ECE</option>
                            <option value="EEE">EEE</option>
                        </select>
                    </div>

                    <div class="form-group mb-3" id="yearGroup" style="display: none;">
                        <label for="year">Year</label>
                        <select name="year" id="year" class="form-control">
                            <option value="">Select Year</option>
                            <option value="1">1st Year</option>
                            <option value="2">2nd Year</option>
                            <option value="3">3rd Year</option>
                            <option value="4">4th Year</option>
                            <option value="5">5th Year</option>
                        </select>
                    </div>

                    <div class="form-group mb-3">
                        <label for="message">Message</label>
                        <textarea name="message" id="message" rows="4" class="form-control" required></textarea>
                    </div>

                    <button type="submit" class="btn btn-primary">Send Notification</button>
                </form>
            </div>

            <!-- SENT TAB -->
            <div class="tab-pane fade" id="sentTab">
                <div class="card p-3 shadow-sm">
                    <h5>Sent Notifications</h5>
                    <jsp:include page="${pageContext.request.contextPath}/components/sentNotifications.jsp" />
                </div>
            </div>

            <!-- RECEIVED TAB -->
            <div class="tab-pane fade" id="receivedTab">
                <div class="card p-3 shadow-sm">
                    <h5>Received Notifications</h5>
                    <jsp:include page="${pageContext.request.contextPath}/components/receivedNotifications.jsp" />
                </div>
            </div>
        </div>
    </div>

    <script>
        $(document).ready(function () {
            $('#recipientType').on('change', function () {
                if ($(this).val() === 'student') {
                    $('#yearGroup').show();
                    $('#year').prop('required', true);
                } else {
                    $('#yearGroup').hide();
                    $('#year').prop('required', false);
                }
            });

            $(".toggle-btn").click(function () {
                $(".sidebar").toggleClass("active");
            });
        });
    </script>
</body>
</html>
