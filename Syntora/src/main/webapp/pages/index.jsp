<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>Syntora</title>
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
        .index-container {
            max-width: 600px;
            width: 100%;
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 40px rgba(59, 130, 246, 0.15);
            text-align: center;
            padding: 50px 40px;
            transition: transform 0.3s ease, box-shadow 0.3s ease;
        }
        .index-container:hover {
            transform: translateY(-10px);
            box-shadow: 0 20px 50px rgba(59, 130, 246, 0.25);
        }
        h1 {
            color: #3b82f6;
            font-weight: 700;
            font-size: 2.5rem;
            margin-bottom: 15px;
            text-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        p {
            color: #1e293b;
            font-size: 1.1rem;
            margin-bottom: 30px;
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
        .icon {
            font-size: 1.2rem;
            margin-right: 8px;
        }
    </style>
</head>
<body>
    <div class="index-container">
        <h1><i class="fas fa-graduation-cap icon"></i>Syntora</h1>
        <p>Unlock your academic potential with a creative twist!</p>
        <div class="d-flex justify-content-center gap-4">
            <a href="register.jsp" class="btn btn-primary"><i class="fas fa-user-plus icon"></i>Register</a>
            <a href="login.jsp" class="btn btn-secondary"><i class="fas fa-sign-in-alt icon"></i>Login</a>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>