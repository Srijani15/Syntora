<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="java.util.UUID" %>
<!DOCTYPE html>
<html>
<head>
    <title>Login - Syntora</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700&display=swap" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            background: linear-gradient(135deg, #dbeafe 0%, #f1f5f9 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
            font-family: 'Poppins', sans-serif;
        }
        .login-container {
            max-width: 450px;
            width: 100%;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.15);
            overflow: hidden;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .login-container:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(59, 130, 246, 0.25);
        }
        .card-header {
            background: #3b82f6;
            padding: 25px;
            color: white;
            text-align: center;
            border-bottom: 4px solid #2563eb;
        }
        .form-control, .form-select {
            border-radius: 10px;
            padding: 12px;
            border: 1px solid #e2e8f0;
            transition: border-color 0.3s ease, box-shadow 0.3s ease;
        }
        .form-control:focus, .form-select:focus {
            border-color: #3b82f6;
            box-shadow: 0 0 8px rgba(59, 130, 246, 0.3);
        }
        .btn {
            padding: 12px 35px;
            border-radius: 50px;
            font-size: 1rem;
            font-weight: 600;
            text-transform: uppercase;
            transition: all 0.3s ease;
        }
        .btn-primary {
            background: #3b82f6;
            border: none;
            box-shadow: 0 4px 15px rgba(59, 130, 246, 0.4);
        }
        .btn-primary:hover {
            background: #2563eb;
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(59, 130, 246, 0.6);
        }
        .btn-secondary {
            background: #10b981;
            border: none;
            color: white;
            box-shadow: 0 4px 15px rgba(16, 185, 129, 0.4);
        }
        .btn-secondary:hover {
            background: #059669;
            transform: scale(1.1);
            box-shadow: 0 6px 20px rgba(16, 185, 129, 0.6);
        }
        .form-group label {
            font-weight: 600;
            color: #1e293b;
            margin-bottom: 6px;
        }
        .alert {
            border-radius: 10px;
            margin-bottom: 20px;
            background: #fee2e2;
            color: #b91c1c;
        }
        .icon {
            font-size: 1.2rem;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="card-header">
            <h2><i class="fas fa-sign-in-alt me-2"></i>Login to Syntora</h2>
        </div>
        <div class="card-body p-4">
            <%
                String csrfToken = UUID.randomUUID().toString();
                session.setAttribute("csrfToken", csrfToken);
            %>
            <c:if test="${param.error == 'true'}">
                <div class="alert">${param.message != null ? param.message : 'Invalid credentials or role. Please try again.'}</div>
            </c:if>
            <form action="${pageContext.request.contextPath}/login" method="post">
                <input type="hidden" name="csrfToken" value="<%= csrfToken %>">
                <div class="form-group mb-3">
                    <label><i class="fas fa-users me-2"></i>Role</label>
                    <select name="role" class="form-select" required>
                        <option value="student">Student</option>
                        <option value="faculty">Faculty</option>
                        <option value="admin">Admin</option>
                    </select>
                </div>
                <div class="form-group mb-3">
                    <label><i class="fas fa-user me-2"></i>Username</label>
                    <input type="text" name="username" class="form-control" pattern="[A-Za-z0-9]{4,}" 
                           title="Username must be alphanumeric and at least 4 characters" required>
                </div>
                <div class="form-group mb-4">
                    <label><i class="fas fa-lock me-2"></i>Password</label>
                    <input type="password" name="password" class="form-control" pattern=".{6,}" 
                           title="Password must be at least 6 characters" required>
                </div>
                <div class="d-flex justify-content-between">
                    <button type="submit" class="btn btn-primary"><i class="fas fa-sign-in-alt icon"></i>Login</button>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-secondary">
                        <i class="fas fa-user-plus icon"></i>Register
                    </a>
                </div>
            </form>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>